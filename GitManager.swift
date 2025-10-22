import Foundation

final class GitManager {
    static func commitAll(message: String) throws {
        try runGit(["add", "."])
        try runGit(["commit", "-m", message])
    }

    static func push() throws {
        try runGit(["push"])
    }

    private static func runGit(_ args: [String]) throws {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git"] + args
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "GitManager", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: output])
        }
    }
}
