// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaNetworkServiceVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")

let package = Package(
  name: "OSCAWeather",
  defaultLocalization: "de",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCAWeather",
      targets: ["OSCAWeather"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    // OSCANetworkService
    packageLocal ? .package(path: "../OSCANetworkService") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscanetworkservice-ios.git",
             .upToNextMinor(from: oscaNetworkServiceVersion)),
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCAWeather",
      dependencies: [/* OSCAEssentials */
                     .product(name: "OSCAEssentials",
                              package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                     .product(name: "OSCANetworkService",
                              package: packageLocal ? "OSCANetworkService" : "oscanetworkservice-ios")],
      path: "OSCAWeather/OSCAWeather",
      exclude:["Info.plist",
               "SupportingFiles"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "OSCAWeatherTests",
      dependencies: ["OSCAWeather",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")],
      path: "OSCAWeather/OSCAWeatherTests",
      exclude:["Info.plist"],
      resources: [.process("Resources")]
    ),
  ]
)
