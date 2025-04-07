//
//  OSCAWeatherObserved.swift
//  OSCAWeather
//
//  Created by Ömer Kurutay on 10.02.22.
//

import Foundation
import OSCAEssentials


// Backwards compatibility
public extension OSCAWeatherObserved {
  var valueArray: [OSCAWeatherObserved.Value]? {
    return self.values?.allValues.compactMap { $0 }
  }
}
extension OSCAWeatherObserved {
  public static var parseClassName : String { return "WeatherObserved" }
}

public struct OSCAWeatherObserved: OSCAParseClassObject, Equatable {
  
  public static func == (lhs: OSCAWeatherObserved, rhs: OSCAWeatherObserved) -> Bool {
    return lhs.objectId == rhs.objectId
  }
  
  /// ObjectId of the sensor station.
  public private(set) var objectId: String?
  /// When the object was created.
  public private(set) var createdAt: Date?
  /// When the object was last updated.
  public private(set) var updatedAt: Date?
  /// A short version of the name.
  public var shortName: String?
  /// Name of the sensor station.
  public var name: String?
  /// District of the sensor station.
  public var district: String?
  /// City of the sensor station.
  public var city: String?
  /// URL to an image of the sensor station.
  public var image: String?
  /// The data provider of the data.
  public var dataProvider: String?
  /// The URL of the data provider.
  public var source: String?
  /// A reference to the data providers unique id.
  public var sourceId: String?
  /// The UTC date when the values were observed.
  public var dateObserved: Date?
  /// Show weather the sensor station is under maintenance.
  public var maintenance: Bool?
  /// The geopoint of the sensor station.
  public var geopoint: ParseGeoPoint?
  /// Array of observed values objects.
  public var values: WeatherValues?
  /// The id from elastic search, which is identical to the `objectId`.
  public var _id: String?

  public init(objectId: String? = nil,
              createdAt: Date? = nil,
              updatedAt: Date? = nil,
              shortName: String?,
              name: String?,
              district: String?,
              city: String?,
              image: String?,
              dataProvider: String?,
              source: String?,
              sourceId: String?,
              dateObserved: Date?,
              maintenance: Bool?,
              geopoint: ParseGeoPoint?,
              values: WeatherValues?
  ) {
    self.shortName = shortName
    self.name = name
    self.district = district
    self.city = city
    self.image = image
    self.dataProvider = dataProvider
    self.source = source
    self.sourceId = sourceId
    self.dateObserved = dateObserved
    self.maintenance = maintenance
    self.geopoint = geopoint
    self.values = values
  }
}

public struct WeatherValues: Codable, Hashable {
  public var swimmingSignal: OSCAWeatherObserved.Value?
  public var temperature: OSCAWeatherObserved.Value?
  public var humidity: OSCAWeatherObserved.Value?
  public var windSpeed: OSCAWeatherObserved.Value?
  public var windDirection: OSCAWeatherObserved.Value?
  public var precipitation: OSCAWeatherObserved.Value?
  public var airPressure: OSCAWeatherObserved.Value?
  public var waterPlayground: OSCAWeatherObserved.Value?
  public var sunrise: OSCAWeatherObserved.Value?
  public var sunset: OSCAWeatherObserved.Value?
  
  public var allValues: [OSCAWeatherObserved.Value?] {
    [swimmingSignal, temperature, humidity, windSpeed, windDirection, precipitation, airPressure, waterPlayground, sunrise, sunset]
  }
  
  private enum CodingKeys: String, CodingKey {
    case swimmingSignal = "badeampel"
    case temperature = "lufttemperatur"
    case humidity = "relative_luftfeuchte"
    case windSpeed = "windgeschwindigkeit_kmh"
    case windDirection = "windrichtung"
    case precipitation = "niederschlagsintensitaet"
    case airPressure = "realtiver_luftdruck"
    case waterPlayground = "wasserspiel"
    case sunrise = "sonnenaufgang"
    case sunset = "sonnenuntergang"
  }
  
  private typealias ValueType = OSCAWeatherObserved.Value
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    swimmingSignal = try? container.decode(ValueType.self, forKey: .swimmingSignal)
    temperature = try? container.decode(ValueType.self, forKey: .temperature)
    humidity = try? container.decode(ValueType.self, forKey: .humidity)
    windSpeed = try? container.decode(ValueType.self, forKey: .windSpeed)
    windDirection = try? container.decode(ValueType.self, forKey: .windDirection)
    precipitation = try? container.decode(ValueType.self, forKey: .precipitation)
    airPressure = try? container.decode(ValueType.self, forKey: .airPressure)
    waterPlayground = try? container.decode(ValueType.self, forKey: .waterPlayground)
    
    swimmingSignal?.type = .swimmingSignal
    temperature?.type = .temperature
    humidity?.type = .humidity
    windSpeed?.type = .windSpeed
    windDirection?.type = .windDirection
    precipitation?.type = .precipitation
    airPressure?.type = .airPressure
    waterPlayground?.type = .waterPlayground
    sunrise?.type = .sunrise
    sunset?.type = .sunset
  }
}

extension OSCAWeatherObserved {
  
  public class Value: Codable, Hashable {
    
    public var unit: String?
    public var value: Double?
    public var name: String?
    public var iconUrl: String?
    public var type: OSCAWeatherObserved.ValueTypes?
    
    private enum CodingKeys: String, CodingKey {
      case unit, value, name, type, iconUrl
    }
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      unit = try? container.decode(String.self, forKey: .unit)
      value = try? container.decode(Double.self, forKey: .value)
      name = try? container.decode(String.self, forKey: .name)
      iconUrl = try? container.decode(String.self, forKey: .iconUrl)
      
      let typeName = try? container.decode(String.self, forKey: .type)
      self.type = OSCAWeatherObserved.ValueTypes.fromName(name: typeName ?? "")
    }
    
    public init(unit: String? = nil, value: Double? = nil, name: String? = nil, type: String? = nil, iconUrl: String?) {
      self.unit = unit
      self.value = value
      self.name = name
      self.iconUrl = iconUrl
      
      self.type = OSCAWeatherObserved.ValueTypes.fromName(name: type ?? "")
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(unit)
      hasher.combine(value)
      hasher.combine(name)
      hasher.combine(type)
      hasher.combine(iconUrl)
    }
    
    public static func == (lhs: OSCAWeatherObserved.Value, rhs: OSCAWeatherObserved.Value) -> Bool {
      return lhs.unit == rhs.unit &&
      lhs.value == rhs.value &&
      lhs.name == rhs.name &&
      lhs.type == rhs.type &&
      lhs.iconUrl == rhs.iconUrl
    }
  }
}

extension OSCAWeatherObserved {
  public enum ValueTypes: Codable, Equatable, Hashable {
    case temperature
    case temperatureAverage
    case uvIndex
    case uvIndexAverage
    case precipitation
    case precipitationAverage
    case humidity
    case humidityAverage
    case airPressure
    case airPressureAverage
    case windSpeed
    case windSpeedAverage
    case windDirection
    case windDirectionAverage
    case globalRadiation
    case waterOnSurface
    
    case sunrise
    case sunset
    
    case waterPlayground
    case swimmingSignal
    
    static func fromName(name: String) -> Self? {
      switch name.lowercased() {
      case "lufttemperatur":
        return .temperature
      case "lufttemperatur_avg":
        return .temperatureAverage
      case "uv_index":
        return .uvIndex
      case "uv_index_avg":
        return .uvIndexAverage
      case "niederschlagsintensitaet":
        return .precipitation
      case "niederschlagsintensitaet_avg":
        return .precipitationAverage
      case "relative_luftfeuchte":
        return .humidity
      case "relative_luftfeuchte_avg":
        return .humidityAverage
      case "realtiver_luftdruck":
        return .airPressure
      case "realtiver_luftdruck_avg":
        return .airPressureAverage
      case "windgeschwindigkeit_kmh":
        return .windSpeed
      case "windgeschwindigkeit_kmh_avg":
        return .windSpeedAverage
      case "windrichtung":
        return .windDirection
      case "windrichtung_avg":
        return .windDirectionAverage
      case "globalstrahlung":
        return .globalRadiation
      case "wasserfilmhoehe_auf_oberflaeche_avg":
        return .waterOnSurface
      case "wasserspiel", "wasserspielplatz":
        return .waterPlayground
      case "badeampel":
        return .swimmingSignal
      default: return nil
      }
    }
  }
}

extension Array where Element == OSCAWeatherObserved.Value {
  public var weatherValues: [OSCAWeatherObserved.Value] {
    return self
      .filter { $0.type != .sunrise && $0.type != .sunset }
      .compactMap { $0 }
  }
  
  public var sunCycleValues: [OSCAWeatherObserved.Value] {
    return self
      .filter { $0.type == .sunrise || $0.type == .sunset  }
  }
}
