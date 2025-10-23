// swift-tools-version:5.9
import Foundation
import Darwin
import PackageDescription

let workspaceRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let cacheRoot = workspaceRoot.appendingPathComponent(".swiftpm-cache", isDirectory: true)
let fileManager = FileManager.default
try? fileManager.createDirectory(at: cacheRoot, withIntermediateDirectories: true)

let swiftModuleCache = cacheRoot.appendingPathComponent("swift-module-cache", isDirectory: true)
try? fileManager.createDirectory(at: swiftModuleCache, withIntermediateDirectories: true)
if getenv("SWIFT_DRIVER_SWIFT_MODULECACHE_PATH") == nil {
    setenv("SWIFT_DRIVER_SWIFT_MODULECACHE_PATH", swiftModuleCache.path, 1)
}

let clangModuleCache = cacheRoot.appendingPathComponent("clang-module-cache", isDirectory: true)
try? fileManager.createDirectory(at: clangModuleCache, withIntermediateDirectories: true)
if getenv("CLANG_MODULE_CACHE_PATH") == nil {
    setenv("CLANG_MODULE_CACHE_PATH", clangModuleCache.path, 1)
}

let spmCache = cacheRoot.appendingPathComponent("spm-cache", isDirectory: true)
try? fileManager.createDirectory(at: spmCache, withIntermediateDirectories: true)
if getenv("SWIFTPM_CACHE_PATH") == nil {
    setenv("SWIFTPM_CACHE_PATH", spmCache.path, 1)
}

let spmConfig = cacheRoot.appendingPathComponent("spm-configuration", isDirectory: true)
try? fileManager.createDirectory(at: spmConfig, withIntermediateDirectories: true)
if getenv("SWIFTPM_CONFIG_PATH") == nil {
    setenv("SWIFTPM_CONFIG_PATH", spmConfig.path, 1)
}

let spmSecurity = cacheRoot.appendingPathComponent("spm-security", isDirectory: true)
try? fileManager.createDirectory(at: spmSecurity, withIntermediateDirectories: true)
if getenv("SWIFTPM_SECURITY_PATH") == nil {
    setenv("SWIFTPM_SECURITY_PATH", spmSecurity.path, 1)
}

if getenv("XDG_CACHE_HOME") == nil {
    setenv("XDG_CACHE_HOME", cacheRoot.path, 1)
}

let package = Package(
    name: "WeWillDoItLive",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "WeWillDoItLive", targets: ["WeWillDoItLive"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WeWillDoItLive",
            path: ".",
            resources: [
                .process("data/specs.json")
            ],
            swiftSettings: [
                .define("ENABLE_PREVIEWS", .when(configuration: .debug))
            ]
        )
    ]
)
