// swift-tools-version: 5.5

import PackageDescription

let package = Package(
	name: "MacBezel",
	platforms: [
		.macOS(.v10_10),
	],
    products: [
        .library(
            name: "MacBezel",
            targets: ["MacBezel"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/dimitarnestorov/AssetCatalog", revision: "d9841fc92c96e26cd96befb1bcb62cb27d4c031b"),
    ],
	targets: [
		.target(
			name: "MacBezel",
			path: "Sources"
		),
		.testTarget(
			name: "MacBezelTests",
			dependencies: ["MacBezel"],
			path: "Tests"
		),
		.executableTarget(
			name: "MacBezel Playground",
			dependencies: ["MacBezel", "AssetCatalog"],
			path: "Playground",
			resources: [
				.process("Resources/Window.xib"),
				.copy("Resources/Icons"),
			]
		),
	]
)
