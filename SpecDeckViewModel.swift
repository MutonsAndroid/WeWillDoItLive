import SwiftUI
import Combine

final class SpecDeckViewModel: ObservableObject {
    @Published private(set) var deck: [SpecTask] = []
    @Published private(set) var completed: [SpecTask] = []
    @Published var isHistoryVisible: Bool = false

    private var completedKeys: Set<String> = []
    private var pollCancellable: AnyCancellable?
    private let pollInterval: TimeInterval

    init(pollInterval: TimeInterval = 3.0, autoRefresh: Bool = true) {
        self.pollInterval = pollInterval
        refresh()
        if autoRefresh {
            beginPolling()
        }
    }

    deinit {
        pollCancellable?.cancel()
    }

    func refresh() {
        let tasks = SpecDeckRepository.loadTasks()
        DispatchQueue.main.async { [weak self] in
            self?.applySnapshot(tasks)
        }
    }

    func toggleHistory() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.9)) {
            isHistoryVisible.toggle()
        }
    }

    func confirmCompletion(for task: SpecTask) {
        completedKeys.insert(task.stableKey)

        var updatedTask = task
        updatedTask.status = .complete
        updatedTask.progress = max(100, updatedTask.progress)

        withAnimation(.easeInOut(duration: 0.35)) {
            deck.removeAll { $0.stableKey == task.stableKey }
            if let existingIndex = completed.firstIndex(where: { $0.stableKey == task.stableKey }) {
                completed[existingIndex] = updatedTask
            } else {
                completed.insert(updatedTask, at: 0)
            }
        }
    }

    func progressBinding(for task: SpecTask) -> Binding<Double> {
        Binding<Double>(
            get: { task.progress },
            set: { [weak self] newValue in
                guard let self else { return }
                guard let index = deck.firstIndex(where: { $0.stableKey == task.stableKey }) else { return }
                deck[index].progress = newValue
            }
        )
    }

    private func beginPolling() {
        pollCancellable = Timer.publish(every: pollInterval, tolerance: pollInterval * 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
    }

    private func applySnapshot(_ tasks: [SpecTask]) {
        var updatedCompleted = completed
        var pending: [SpecTask] = []

        for task in tasks {
            if completedKeys.contains(task.stableKey) || task.status == .complete {
                completedKeys.insert(task.stableKey)

                let normalizedTask = normalizeCompleted(task)
                if let existingIndex = updatedCompleted.firstIndex(where: { $0.stableKey == normalizedTask.stableKey }) {
                    updatedCompleted[existingIndex] = normalizedTask
                } else {
                    updatedCompleted.append(normalizedTask)
                }
            } else {
                pending.append(task)
            }
        }

        deck = pending
        completed = deduplicated(updatedCompleted)
    }

    private func normalizeCompleted(_ task: SpecTask) -> SpecTask {
        var normalized = task
        normalized.status = .complete
        normalized.progress = max(task.progress, 100)
        return normalized
    }

    private func deduplicated(_ tasks: [SpecTask]) -> [SpecTask] {
        var seen: Set<String> = []
        var result: [SpecTask] = []
        for task in tasks {
            guard !seen.contains(task.stableKey) else { continue }
            seen.insert(task.stableKey)
            result.append(task)
        }
        return result
    }
}
