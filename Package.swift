// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MLXLanguageModel",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(
            url: "https://github.com/huggingface/AnyLanguageModel.git",
            from: "0.8.0",
            traits: ["MLX"]
        ),
        // Workaround for SwiftPM trait dependency-resolution edge cases.
        // AnyLanguageModel's MLX trait depends on mlx-swift-lm >= 2.25.5.
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", from: "2.25.5"),
    ],
    targets: [
        .testTarget(
            name: "MLXLanguageModelTests",
            dependencies: [
                .product(name: "AnyLanguageModel", package: "AnyLanguageModel"),
            ]
        ),
    ]
)
