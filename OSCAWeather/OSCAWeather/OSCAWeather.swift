//
//  OSCAWeather.swift
//  OSCAWeather
//
//  Created by Ömer Kurutay on 10.02.22.
//  Reviewed by Stephan Breidenbach on 21.06.22

import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public struct OSCAWeatherDependencies {
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  let analyticsModule: OSCAAnalyticsModule?

  public init(networkService: OSCANetworkService,
              userDefaults: UserDefaults,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.networkService = networkService
    self.userDefaults = userDefaults
    self.analyticsModule = analyticsModule
  } // end public memberwise init
} // end public struct OSCAWeatherDependencies

public struct OSCAWeather: OSCAModule {
  /// module DI container
  var moduleDIContainer: OSCAWeatherDIContainer!

  let transformError: (OSCANetworkError) -> OSCAWeatherError = { networkError in
    switch networkError {
    case OSCANetworkError.invalidResponse:
      return OSCAWeatherError.networkInvalidResponse
    case OSCANetworkError.invalidRequest:
      return OSCAWeatherError.networkInvalidRequest
    case let OSCANetworkError.dataLoadingError(statusCode: code, data: data):
      return OSCAWeatherError.networkDataLoading(statusCode: code, data: data)
    case let OSCANetworkError.jsonDecodingError(error: error):
      return OSCAWeatherError.networkJSONDecoding(error: error)
    case OSCANetworkError.isInternetConnectionError:
      return OSCAWeatherError.networkIsInternetConnectionFailure
    } // end switch case
  } // end let transformError

  /// Moduleversion
  public var version: String = "1.0.3"
  /// Bundle prefix of the module
  public var bundlePrefix: String = "de.osca.weather"
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!

  private var networkService: OSCANetworkService

  public private(set) var userDefaults: UserDefaults

  /**
   create module and inject module dependencies

   ** This is the only way to initialize the module!!! **
   - Parameter moduleDependencies: module dependencies
   ```
   call: OSCAWeather.create(with moduleDependencies)
   ```
   */
  public static func create(with moduleDependencies: OSCAWeatherDependencies) -> OSCAWeather {
    var module: Self = Self(networkService: moduleDependencies.networkService,
                            userDefaults: moduleDependencies.userDefaults)
    module.moduleDIContainer = OSCAWeatherDIContainer(dependencies: moduleDependencies)

    return module
  } // end public static func create

  /// Initializes the weather module
  /// - Parameter networkService: Your configured network service
  private init(networkService: OSCANetworkService,
               userDefaults: UserDefaults) {
    self.networkService = networkService
    self.userDefaults = userDefaults
    var bundle: Bundle?
    #if SWIFT_PACKAGE
      bundle = Bundle.module
    #else
      bundle = Bundle(identifier: bundlePrefix)
    #endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  } // end public init
} // end public struct OSCAWeather

extension OSCAWeather {
  /// Downloads sensor stations from parse-server
  /// - Parameter limit: Limits the amount of sensor stations that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: An array of sensor stations
  public func getWeatherObserved(limit: Int = 1000, query: [String: String] = [:]) -> AnyPublisher<Result<[OSCAWeatherObserved], Error>, Never> {
    var parameters = query
    parameters["limit"] = "\(limit)"

    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
      
    return networkService
      .download(OSCAClassRequestResource<OSCAWeatherObserved>.weatherObserved(
        baseURL: networkService.config.baseURL,
        headers: headers,
        query: parameters))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<[OSCAWeatherObserved], Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }
} // end extension public struct OSCAWeather

// MARK: - elastic search weather observed

extension OSCAWeather {
  public typealias OSCAWeatherObservedPublisher = AnyPublisher<[OSCAWeatherObserved], OSCAWeatherError>

  /// ```console
  /// curl -vX POST 'https://parse-dev.solingen.de/functions/elastic-search' \
  ///  -H "X-Parse-Application-Id: <APP_ID>" \
  ///  -H "X-Parse-Client-Key: <CLIENT_KEY>" \
  ///  -H 'Content-Type: application/json' \
  ///  -d '{"index":"weather_observed","query":"Mitte"}'
  /// ```
  public func elasticSearch(for query: String, at index: String = "weather_observed") -> OSCAWeatherObservedPublisher {
    guard !query.isEmpty,
          !index.isEmpty
    else {
      return Empty(completeImmediately: true,
                   outputType: [OSCAWeatherObserved].self,
                   failureType: OSCAWeatherError.self).eraseToAnyPublisher()
    } // end guard
    // init cloud function parameter object
    let cloudFunctionParameter = ParseElasticSearchQuery(index: index,
                                                         query: query)

    var publisher: AnyPublisher<[OSCAWeatherObserved], OSCANetworkError>
    #if MOCKNETWORK

    #else
      publisher = networkService.fetch(OSCAFunctionRequestResource<ParseElasticSearchQuery>
        .elasticSearch(baseURL: networkService.config.baseURL,
                       headers: networkService.config.headers,
                       cloudFunctionParameter: cloudFunctionParameter))
    #endif
    return publisher
      .mapError(transformError)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  } // end public func elasticSearch for query at index
} // end extension public struct OSCAWeather

extension OSCAWeather {
  /// UserDefaults object keys
  public enum Keys: String {
    case userDefaultsWeatherObserved = "OSCAWeather_favouriteWeatherObserved"
  }
}
