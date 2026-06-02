// SPEC-STUB — authored on Windows, NEVER compiled here. Mac is the first compile (External).
// NEPacketTunnelProvider — the downloadable web/DNS filter. Captures DNS and re-issues each query as DoH to
// KolBo's resolver for the enrollment's tier; FAIL-CLOSED to the shomer-eynayim floor (.t) when no tier is
// configured or the feed is unreachable. SNI/host filtering via #6's proxy; NO TLS MITM (honest ceiling, #84).
//
// Routing target is READ from #6's SSOT (D:/kolbo-dns/resolver/exports/resolver_host_ssot.json) — do NOT diverge:
//   DoH path:  https://doh.kolbofilter.com/dns-query/<tier>        floor tier: shomer-eynayim (strictest)
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    // FAIL-CLOSED floor (.t): the strictest tier, used when tier is nil/empty or the feed can't be reached.
    private static let FLOOR_TIER = "shomer-eynayim"
    private static func dohEndpoint(forTier tier: String?) -> String {
        let t = (tier?.isEmpty == false) ? tier! : FLOOR_TIER     // never fall open to system DNS
        return "https://doh.kolbofilter.com/dns-query/\(t)"
    }

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tier = (protocolConfiguration as? NETunnelProviderProtocol)?
            .providerConfiguration?["tier"] as? String
        let doh = Self.dohEndpoint(forTier: tier)

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        // Capture all traffic so DNS is forced through the in-tunnel DoH resolver (no plaintext :53 escapes).
        let ipv4 = NEIPv4Settings(addresses: ["10.64.0.2"], subnetMasks: ["255.255.255.255"])
        ipv4.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4
        // DNS handled inside the tunnel via DoH; system DNS is overridden to the tunnel.
        settings.dnsSettings = NEDNSSettings(servers: ["10.64.0.1"])

        setTunnelNetworkSettings(settings) { error in
            if let error = error { completionHandler(error); return }
            self.startDohResolver(endpoint: doh)      // resolve every captured query via DoH to KolBo (#6)
            self.startProxyForwarding()               // forward flows to #6's proxy (SNI/host filtering, no MITM)
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    // The DoH client + the packet pump are ported from the Android VpnService Tier-1 path (decision logic shared).
    private func startDohResolver(endpoint: String) { /* SPEC-STUB: DoH query loop to `endpoint` */ }
    private func startProxyForwarding() { /* SPEC-STUB: forward to #6's proxy; host/SNI filter; no TLS MITM */ }
}
