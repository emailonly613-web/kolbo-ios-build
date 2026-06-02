// SPEC-STUB — authored on Windows, NEVER compiled here. Mac is the first compile (External).
// Installs + enables the KolBo packet-tunnel VPN via NETunnelProviderManager. The user APPROVES the config on
// first save (system consent) and can REMOVE it in Settings ▸ VPN — REVOCABLE by design (Tier-1 voluntary, #84).
import NetworkExtension

enum VpnConfigurator {
    private static let tunnelBundleId = "com.kolbo.shomer.tunnel"

    static func installAndEnable(tier: String) async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        let manager = managers.first ?? NETunnelProviderManager()

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = tunnelBundleId
        proto.serverAddress = "KolBo Filter"            // display label; real routing is DoH-to-#6 in the tunnel
        // Per-enrollment tier only. NO secret/token baked here — tokens ride the authenticated feed (.s).
        proto.providerConfiguration = ["tier": tier]

        manager.protocolConfiguration = proto
        manager.localizedDescription = "KolBo Filter"
        manager.isEnabled = true
        try await manager.saveToPreferences()           // ← triggers the one-time user-consent prompt
    }

    static func isEnabled() async -> Bool {
        (try? await NETunnelProviderManager.loadAllFromPreferences())?.first?.isEnabled ?? false
    }

    static func disable() async throws {
        guard let manager = try await NETunnelProviderManager.loadAllFromPreferences().first else { return }
        manager.isEnabled = false
        try await manager.saveToPreferences()
    }
}

/// Per-enrollment config read from the authenticated feed at runtime (NOT compiled in). Fail-closed default = floor.
enum EnrollmentConfig {
    static func currentTier() -> String {
        // Real impl: read the tier the feed wrote into the App Group; absent => the strictest floor (.t).
        SharedStore.tier() ?? "shomer-eynayim"
    }
}
