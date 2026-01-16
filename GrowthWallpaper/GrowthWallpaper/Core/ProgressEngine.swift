import Foundation

final class ProgressEngine {
    func compute(completed: Int, steps: Int) -> ProgressSnapshot {
        let ratio = min(1.0, Double(completed) / Double(max(steps, 1)))
        let index = min(9, max(0, Int(ceil(ratio * 10))))
        return ProgressSnapshot(completedIssues: completed, ratio: ratio, imageIndex: index)
    }
}
