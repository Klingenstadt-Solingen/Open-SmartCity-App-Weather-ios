//
//  OSCARequestResource+Weather.swift
//  OSCAWeather
//
//  Created by Ömer Kurutay on 10.02.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  /// ClassReqestRessource for sensor station
  ///
  /// ```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/WeatherObserved'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use OSCAClassRequestResource
  static func weatherObserved(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<OSCAWeatherObserved> {
    let parseClass = "WeatherObserved"
    return OSCAClassRequestResource<OSCAWeatherObserved>(
      baseURL: baseURL,
      parseClass: parseClass,
      parameters: query,
      headers: headers)
  }
}
