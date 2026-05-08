// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "cordova-plugin-marketingcloudsdk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "cordova-plugin-marketingcloudsdk",
            targets: ["cordova-plugin-marketingcloudsdk"])
    ],
    dependencies: [
        .package(url: "https://github.com/apache/cordova-ios.git", branch: "master"),
        .package(url: "https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS.git", from: "8.1.1")
    ],
    targets: [
        .target(
            name: "cordova-plugin-marketingcloudsdk",
            dependencies: [
                .product(name: "Cordova", package: "cordova-ios"),
                .product(name: "MarketingCloudSDK", package: "MarketingCloudSDK-iOS")
            ],
            path: "src/ios",
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedFramework("CoreLocation")
            ])
    ]
)