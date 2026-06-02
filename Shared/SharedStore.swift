// SPEC-STUB — authored on Windows, NEVER compiled here. Mac is the first compile (External).
// The App-Group bridge: the app writes the enrollment-fed config (tier + number sets) here; the extensions read
// it. Shared source — compiled into the app AND all three extension targets (see project.yml `Shared`).
// NOTHING secret is stored compiled-in; per-enrollment values arrive at runtime via the authenticated feed (.s).
import Foundation

enum SharedStore {
    static let appGroup = "group.com.kolbo.shomer"
    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    /// The enrollment's filtering tier; nil => callers fail CLOSED to the strictest floor (shomer-eynayim, .t).
    static func tier() -> String? { defaults?.string(forKey: "tier") }

    struct Labeled { let number: Int64; let label: String }

    /// Blocked numbers (E.164 as Int64), strictly ascending as CallKit requires.
    static func blockedNumbersAscending() -> [Int64] {
        ((defaults?.array(forKey: "blockedNumbers") as? [Int64]) ?? []).sorted()
    }

    /// Labeled numbers, ascending by number.
    static func labeledNumbersAscending() -> [Labeled] {
        let raw = (defaults?.array(forKey: "labeledNumbers") as? [[String: Any]]) ?? []
        return raw.compactMap { dict in
            guard let n = dict["number"] as? Int64, let l = dict["label"] as? String else { return nil }
            return Labeled(number: n, label: l)
        }.sorted { $0.number < $1.number }
    }
}
