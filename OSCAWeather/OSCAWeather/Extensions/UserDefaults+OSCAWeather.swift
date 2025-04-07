//
//  UserDefaults+OSCAWeather.swift
//  OSCAWeather
//
//  Created by Ömer Kurutay on 21.07.22.
//

import OSCAEssentials
import Foundation

extension UserDefaults: OSCAWeatherUserDefaults {
  public func setOSCAWeatherObserved(_ objectId: String) -> Void {
    set(objectId, forKey: OSCAWeather.Keys.userDefaultsWeatherObserved.rawValue)
    NotificationCenter.default.post(
      name: .userWeatherStationDidChange,
      object: nil,
      userInfo: nil)
  }
  
  public func getOSCAWeatherObserved() -> String? {
    return string(forKey: OSCAWeather.Keys.userDefaultsWeatherObserved.rawValue)
  }
}
