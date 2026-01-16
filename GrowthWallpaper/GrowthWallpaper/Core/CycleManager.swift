import Foundation

enum CycleManager {
    static func cycleStart(cadence: ResetCadence) -> Date {
        let calendar = Calendar.current
        let now = Date()

        switch cadence {
        case .daily:
            return calendar.startOfDay(for: now)
        case .weekly:
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            return calendar.date(from: comps) ?? calendar.startOfDay(for: now)
        }
    }

    static func iso(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    static func fromISO(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }
}
