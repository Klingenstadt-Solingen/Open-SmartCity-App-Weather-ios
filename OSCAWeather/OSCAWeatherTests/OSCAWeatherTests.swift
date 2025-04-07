// Reviewed by Stephan Breidenbach on 21.06.2022
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import Foundation
import Combine
import OSCANetworkService
import XCTest
import OSCATestCaseExtension
@testable import OSCAWeather

final class OSCAWeatherTests: XCTestCase {
  static let moduleVersion = "1.0.3"
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws -> Void {
    try super.setUpWithError()
    // initialize cancellables
    self.cancellables = []
  }// end setupWithError
  
  func testModuleInit() throws -> Void {
    let module = try makeDevModule()
    XCTAssertNotNil(module)
    XCTAssertEqual(module.bundlePrefix, "de.osca.weather")
    XCTAssertEqual(module.version, OSCAWeatherTests.moduleVersion)
    let bundle = OSCAWeather.bundle
    XCTAssertNotNil(bundle)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testDownload() throws -> Void {
    var weatherObserved: [OSCAWeatherObserved] = []
    var error: Error?
    
    let expectation = self.expectation(description: "GetWeatherObserved")
    let module = try makeDevModule()
    XCTAssertNotNil(module)
    module.getWeatherObserved(limit: 1)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
        }
      } receiveValue: { result in
        switch result {
        case let .success(objects):
          weatherObserved = objects
        case let .failure(encounteredError):
          error = encounteredError
        }
      }
      .store(in: &cancellables)
    
    waitForExpectations(timeout: 10)
    
    XCTAssertNil(error)
    XCTAssertTrue(weatherObserved.count == 1)
  }
  
  func testElasticSearchForWeatherObserved() throws -> Void {
    //var weatherObserveds: [OSCAWeatherObserved] = []
    let queryString = "Mitte"
    var error: Error?
    
    let expectation = self.expectation(description: "elasticSearchForWeatherObserved")
    let module = try makeDevModule()
    XCTAssertNotNil(module)
    module.elasticSearch(for: queryString)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }// end switch case
      } receiveValue: { weatherObservedsFromNetwork in
        //weatherObserveds = weatherObservedsFromNetwork
      }// end sink
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(error)
  }// end testElasticSearchForWeatherObserved
}// end final calss OSCAWeatherTests

// MARK: - factory methods
extension OSCAWeatherTests {
  public func makeDevModuleDependencies() throws -> OSCAWeatherDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.weather")
    let dependencies = OSCAWeatherDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCAWeather {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCAWeather.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCAWeatherDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.weather")
    let dependencies = OSCAWeatherDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCAWeather {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCAWeather.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
}// end extension final class OSCAEventsTests
#endif
