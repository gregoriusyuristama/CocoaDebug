// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CocoaDebug",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "CocoaDebug", targets: ["CocoaDebug"])
    ],
    targets: [
        .binaryTarget(
            name: "CocoaDebug",
            path: "xcframework/CocoaDebug.xcframework"
        )
    ]
)
