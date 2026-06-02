// SPEC-STUB — authored on Windows, NEVER compiled here. The Mac is the first compile (External barometer).
// KolBo iOS Tier-1 downloadable filtering app — main app. Installs/enables the on-device filtering VPN and
// shows an HONEST, REVOCABLE status (mirrors the Android VoluntaryOnboarding: never a tamper-proof claim).
import SwiftUI
import NetworkExtension

@main
struct KolboShomerApp: App {
    var body: some Scene {
        WindowGroup { StatusView() }
    }
}

struct StatusView: View {
    @State private var vpnOn = false
    @State private var busy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("KolBo").font(.largeTitle.bold())
            // HONEST status (#84): voluntary => "you can turn this off"; never a tamper-proof claim it can't back.
            Text(vpnOn ? "Filtering ON — voluntary (you can turn this off)"
                       : "Filtering OFF — tap to turn on the KolBo filter")
                .foregroundStyle(vpnOn ? .green : .secondary)

            Button(vpnOn ? "Turn filtering off" : "Turn filtering on") {
                Task { await toggle() }
            }.disabled(busy)

            Divider()
            // The two channels Apple permits on a downloadable app — surfaced honestly.
            Label("Web/content filtering — via the VPN you approve", systemImage: "globe")
            Label("Junk texts from unknown numbers — enable in Settings ▸ Messages", systemImage: "message")
            Label("Call blocking — enable in Settings ▸ Phone ▸ Call Blocking", systemImage: "phone")
            Text("iPhone cannot filter texts/calls from your saved contacts or iMessage — an Apple limit.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding()
        .task { vpnOn = await VpnConfigurator.isEnabled() }
    }

    private func toggle() async {
        busy = true; defer { busy = false }
        do {
            if vpnOn { try await VpnConfigurator.disable() }
            // tier arrives from the authenticated enrollment feed at runtime; floor = shomer-eynayim (.t)
            else { try await VpnConfigurator.installAndEnable(tier: EnrollmentConfig.currentTier()) }
            vpnOn = await VpnConfigurator.isEnabled()
        } catch { /* surface a real error to the user; never silently claim ON */ }
    }
}
