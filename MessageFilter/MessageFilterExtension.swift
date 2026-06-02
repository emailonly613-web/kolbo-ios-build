// SPEC-STUB — authored on Windows, NEVER compiled here. Mac is the first compile (External).
// ILMessageFilterExtension — UNKNOWN-sender SMS/MMS ONLY. For an unknown sender the extension receives the
// `sender` and the `messageBody` (ILMessageFilterQueryRequest) and classifies BY CONTENT — offline, or deferred
// to KolBo's judge via the declared ILMessageFilterExtensionNetworkURL (Info.plist). It is NEVER invoked for
// known contacts or iMessage (Apple-capped — that content reaches no extension). Honest ceiling, #84.
import IdentityLookup

class MessageFilterExtension: ILMessageFilterExtension, ILMessageFilterQueryHandling {

    func handle(_ queryRequest: ILMessageFilterQueryRequest,
                context: ILMessageFilterExtensionContext,
                completion: @escaping (ILMessageFilterQueryResponse) -> Void) {

        // 1) Offline decision from the cached catalog (ported from the Android decideInboundMessage engine:
        //    keyword/regex + tiers). messageBody is the unknown-sender text Apple hands us.
        let offline = Self.offlineClassify(body: queryRequest.messageBody ?? "", sender: queryRequest.sender ?? "")
        if let action = offline {
            let resp = ILMessageFilterQueryResponse(); resp.action = action
            completion(resp); return
        }

        // 2) Unknown/uncertain → defer to KolBo's judge. The SYSTEM POSTs sender+body to the declared
        //    ILMessageFilterExtensionNetworkURL (PUBLIC host; per-enrollment token rides the feed, NOT baked, .s).
        context.deferQueryRequestToNetwork { (networkResponse, error) in
            let resp = ILMessageFilterQueryResponse()
            // Fail-SAFE: if the judge is unreachable, do NOT silently allow — mark as junk (.t). (Real impl parses
            // networkResponse?.data for the judge's verdict; ILNetworkResponse carries the HTTP response + data, not an action.)
            resp.action = .junk
            completion(resp)
        }
    }

    /// Offline catalog classify. Returns nil to defer to the network judge. (.junk / .promotion / .transaction / .allow)
    private static func offlineClassify(body: String, sender: String) -> ILMessageFilterAction? {
        // SPEC-STUB: port the Android keyword/regex catalog; return .junk on a high-severity hit, nil to defer.
        return nil
    }
}
