import SwiftUI
import AppKit
import Highlightr

struct OpenCodeView: View {
    @EnvironmentObject var engine: OpenCodeEngine
    @State private var highlightedOutput = AttributedString()
    @State private var autoScroll = true
    @State private var isEnvEditorPresented = false
    @State private var showingHistory = false

    private let highlightr: Highlightr? = {
        let instance = Highlightr()
        instance?.setTheme(to: "atom-one-dark")
        let font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        instance?.theme.setCodeFont(font)
        return instance
    }()
    private let bottomAnchorID = "opencode-bottom-anchor"

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    Text(displayText)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(bottomAnchorID)
                }
                .background(AppTheme.openCodeBackground)
                .onAppear {
                    highlight(engine.output)
                    scrollToBottom(proxy)
                }
                .onChange(of: engine.output) { newValue in
                    highlight(newValue)
                    guard autoScroll else { return }
                    scrollToBottom(proxy)
                }
            }

            ProgressView(value: engine.progress, total: 1.0)
                .progressViewStyle(.linear)
                .tint(engine.isRunning ? AppTheme.progressActive : AppTheme.progressIdle)
                .opacity(engine.isRunning ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: engine.isRunning)
                .padding(.horizontal, 8)

            controlBar
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
        }
        .background(AppTheme.openCodeBackground)
        .foregroundStyle(AppTheme.openCodeText)
        .sheet(isPresented: $isEnvEditorPresented) {
            EnvEditorView(config: $engine.config)
                .padding()
                .frame(minWidth: 400, minHeight: 300)
                .background(AppTheme.background)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(history: engine.history) { command in
                showingHistory = false
                engine.run(command: command)
            }
            .frame(minWidth: 500, minHeight: 400)
            .background(AppTheme.background)
        }
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            Button(engine.isRunning ? "Cancel" : "Clear") {
                if engine.isRunning {
                    engine.cancel()
                } else {
                    engine.output = ""
                    highlightedOutput = AttributedString()
                }
            }
            .keyboardShortcut(.escape, modifiers: [])

            Toggle("Auto-scroll", isOn: $autoScroll)
                .toggleStyle(.switch)
                .tint(AppTheme.progressActive)
                .foregroundStyle(AppTheme.textSecondary)

            Menu {
                ForEach(OpenCodeConfig.Interpreter.allCases, id: \.self) { interpreter in
                    Button(interpreter.rawValue) {
                        engine.config.defaultInterpreter = interpreter
                        engine.config.save()
                    }
                }
            } label: {
                Label(engine.config.defaultInterpreter.rawValue, systemImage: "chevron.down")
                    .labelStyle(.titleAndIcon)
            }
            .menuStyle(.borderlessButton)

            Button("Env Vars") {
                isEnvEditorPresented = true
            }
            .buttonStyle(.bordered)

            Button("History") {
                showingHistory = true
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("View Logs") {
                NSWorkspace.shared.open(engine.logURL)
            }
        }
    }

    private var displayText: AttributedString {
        highlightedOutput.characters.isEmpty ? AttributedString("🟢 Ready") : highlightedOutput
    }

    private func highlight(_ text: String) {
        guard !text.isEmpty else {
            highlightedOutput = AttributedString("🟢 Ready")
            return
        }

        if let highlighted = highlightr?.highlight(text, as: "swift"),
           let attributed = try? AttributedString(highlighted, including: \.appKit) {
            highlightedOutput = attributed
        } else {
            highlightedOutput = AttributedString(text)
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
        }
    }
}
