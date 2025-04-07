//
//  OSCAWeatherUserDefaults.swift
//  OSCAWeather
//
//  Created by Ömer Kurutay on 21.07.22.
//

import Foundation

public protocol OSCAWeatherUserDefaults {
  func setOSCAWeatherObserved(_ weatherObserved: String) -> Void
  func getOSCAWeatherObserved() -> String?
}
