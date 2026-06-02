// SPEC-STUB — authored on Windows, NEVER compiled here. Mac is the first compile (External).
// CXCallDirectoryProvider — block + label incoming calls BY NUMBER, from the set the app wrote into the shared
// App Group (group.com.kolbo.shomer). No call audio / no content (iron-wall). Numbers are E.164 Int64, ASCENDING
// (Apple requires strictly increasing sequential entries). Honest ceiling, #84: number-only, never per-call logic.
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        // Blocking entries (ascending). The feed wrote these into the App Group; absent => empty (no false blocks).
        for number in SharedStore.blockedNumbersAscending() {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
        // Identification/label entries (ascending) — e.g. label a known spam prefix.
        for entry in SharedStore.labeledNumbersAscending() {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: entry.number, label: entry.label)
        }
        context.completeRequest()
    }
}
