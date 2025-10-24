import Foundation
import SwiftUI
import Combine

final class OpenCodeEngine: ObservableObject {
    @Published var output: String = ""
    @Published var isRunning: Bool = false
    @Published var progress: Double = 0.0
    @Published var config: OpenCodeConfig = OpenCodeConfig.load()
    @Published var history = OpenCodeHistory()

    let logURL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("Documents/OpenCodeLogs.txt")

    private let timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private var process: Process?
    private var outputObserver: AnyCancellable?
    private var errorObserver: AnyCancellable?
    private var activeCommand: String = ""
    private var bufferedOutput: String = ""
    private var cancellationRequested = false
    private var lastCommandInput: String = ""

    init() {
        ensureLogFileExists()
        restoreLastSession()
    }

    func run(command: String, args: [String] = []) {
        guard !isRunning else { return }

        resetObservers()
        bufferedOutput = ""
        cancellationRequested = false
        lastCommandInput = command

        let (executable, finalArgs, description) = resolvedCommand(for: command, args: args)
        activeCommand = description

        DispatchQueue.main.async {
            self.output = "⏳ Running \(description)...\n"
            self.bufferedOutput = self.output
            self.progress = 0.02
            self.isRunning = true
            self.persistLastSession()
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = finalArgs
        process.environment = mergedEnvironment()

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        self.process = process

        let outputHandle = outputPipe.fileHandleForReading
        let errorHandle = errorPipe.fileHandleForReading

        let outputPublisher = NotificationCenter.default
            .publisher(for: FileHandle.readCompletionNotification, object: outputHandle)
        let errorPublisher = NotificationCenter.default
            .publisher(for: FileHandle.readCompletionNotification, object: errorHandle)

        outputHandle.readInBackgroundAndNotify()
        errorHandle.readInBackgroundAndNotify()

        outputObserver = outputPublisher.sink { [weak self] _ in
            guard let self else { return }
            let data = outputHandle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8), !chunk.isEmpty else { return }

            DispatchQueue.main.async {
                self.appendOutput(chunk)
                self.progress = min(self.progress + 0.01, 0.95)
                self.appendChunkToSessionFile(chunk)
            }

            outputHandle.readInBackgroundAndNotify()
        }

        errorObserver = errorPublisher.sink { [weak self] _ in
            guard let self else { return }
            let data = errorHandle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8), !chunk.isEmpty else { return }

            DispatchQueue.main.async {
                self.appendOutput("❌ " + chunk)
                self.appendChunkToSessionFile("❌ " + chunk)
            }

            errorHandle.readInBackgroundAndNotify()
        }

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.finishRun()
            }
        }

        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                self.output = "❌ Failed to start: \(error)"
                self.isRunning = false
                self.progress = 0.0
                self.log(self.activeCommand, self.output)
            }
        }
    }

    func cancel() {
        guard isRunning else { return }
        cancellationRequested = true
        process?.terminate()
        appendOutput("\n🟥 Process canceled by user.\n")
        progress = 0.0
        isRunning = false
        persistLastSession()
    }

    private func appendOutput(_ chunk: String) {
        output.append(chunk)
        bufferedOutput.append(chunk)
    }

    private func finishRun() {
        guard isRunning || cancellationRequested else { return }
        isRunning = false
        progress = cancellationRequested ? 0.0 : 1.0
        log(activeCommand, bufferedOutput)
        let item = OpenCodeHistoryItem(
            command: lastCommandInput,
            interpreter: config.defaultInterpreter.rawValue,
            output: bufferedOutput
        )
        history.add(item)
        persistLastSession()
        resetObservers()
    }

    private func resetObservers() {
        outputObserver?.cancel()
        errorObserver?.cancel()
        outputObserver = nil
        errorObserver = nil
        process = nil
    }

    private func resolvedCommand(for command: String, args: [String]) -> (String, [String], String) {
        let snippet = command.isEmpty ? " " : command
        let interpreter = config.defaultInterpreter

        let executable: String
        let finalArgs: [String]

        switch interpreter {
        case .swift:
            executable = "/usr/bin/env"
            finalArgs = ["swift", "-e", snippet] + args
        case .python:
            executable = config.pythonPath.isEmpty ? "/usr/bin/python3" : config.pythonPath
            finalArgs = ["-c", snippet] + args
        case .shell:
            executable = config.shellPath.isEmpty ? "/bin/zsh" : config.shellPath
            finalArgs = ["-c", snippet] + args
        }

        let description = ([executable] + finalArgs).joined(separator: " ")
        return (executable, finalArgs, description)
    }

    private func mergedEnvironment() -> [String: String] {
        ProcessInfo.processInfo.environment.merging(config.envVars) { _, custom in custom }
    }

    private func appendChunkToSessionFile(_ chunk: String) {
        try? chunk.appendLine(to: OpenCodeConfig.lastSessionURL)
    }

    private func persistLastSession() {
        try? output.write(to: OpenCodeConfig.lastSessionURL, atomically: true, encoding: .utf8)
    }

    func restoreLastSession() {
        guard let data = try? String(contentsOf: OpenCodeConfig.lastSessionURL) else { return }
        output = data
    }

    private func log(_ command: String, _ result: String) {
        guard !command.isEmpty else { return }
        ensureLogFileExists()

        let timestamp = timestampFormatter.string(from: Date())
        let entry = "\n[\(timestamp)] $ \(command)\n\(result)\n"
        try? entry.appendLine(to: logURL)
    }

    private func ensureLogFileExists() {
        let directory = logURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: logURL.path) {
            try? "".write(to: logURL, atomically: true, encoding: .utf8)
        }
    }
}

extension String {
    func appendLine(to url: URL) throws {
        let data = (self + "\n").data(using: .utf8)!
        if FileManager.default.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } else {
            try data.write(to: url, options: .atomic)
        }
    }
}
