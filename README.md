# kolbo-ios — Tier-1 downloadable filtering app (project skeleton)

**Status: SPEC-STUB skeleton — authored on Windows, NEVER compiled here.** The Swift/Xcode build runs on a Mac;
that compile is the **first build (External barometer)**. This tree exists so the Mac build is a *faithful
execution* of the spec, not a re-design.

- **Spec / contract (read first):** [`../IOS_DOWNLOADABLE_APP_BUILD_SPEC.md`](../IOS_DOWNLOADABLE_APP_BUILD_SPEC.md)
- **Consistency checker (`.z7`):** `node ../policy-server/scripts/check-ios-downloadable-spec.mjs` → `IOS_DOWNLOADABLE_SPEC_READY`

## What it is
The iOS sibling of the Android Tier-1 voluntary app: a downloadable App-Store app (no MDM, no supervision) that
filters via the three channels Apple permits an unsupervised app —
- **Web/DNS** via a user-approved packet-tunnel VPN routed to KolBo's resolver (`PacketTunnel/`),
- **Unknown-sender SMS/MMS** junk/content filtering (`MessageFilter/`),
- **Call block/label by number** (`CallDirectory/`).

It is **revocable** (the user can turn it off) — the honest Tier-1 posture (#84). Tamper-proof confinement is the
separate supervised Tier-2 `.mobileconfig` profile (`../policy-server/ios-mdm/`), not this app.

## Layout
```
project.yml              XcodeGen project (app + 3 extension targets)
App/                     main app: VPN install/enable + honest revocable status UI
PacketTunnel/            NEPacketTunnelProvider — DoH to KolBo's resolver, fail-closed to the floor (.t)
MessageFilter/           ILMessageFilterExtension — unknown-sender only
CallDirectory/           CXCallDirectoryProvider — block/label by number
Shared/                  App-Group bridge (compiled into all targets)
```

## Build on the Mac (the resourced follow — see the spec §0 gates)
1. **Gates:** a cloud Mac (#4 provisions) + the operator's **Apple Developer account** (App IDs, signing).
2. `brew install xcodegen` (once).
3. `cd kolbo-ios && xcodegen generate` → `open KolboShomer.xcodeproj`.
4. Set `KOLBO_APPLE_TEAM_ID`; register the 4 App IDs + the App Group `group.com.kolbo.shomer` + the
   Network-Extensions / Message-Filter / Call-Directory capabilities in the developer portal.
5. `xcodebuild -scheme KolboShomer archive` — **resolve the first compile of the Swift spec-stubs** (they are
   structurally complete but never compiled on Windows).
6. On-device prove (real iPhone) → TestFlight → App Store. **All External — never folded into Internal.**

## Discipline carried in
- **No secret in the binary** (`.s`) — per-enrollment tier/token via the authenticated feed at runtime, never baked.
- **Fail-closed** (`.t`) — no tier / unreachable judge ⇒ strictest floor (`shomer-eynayim`) / mark junk, never open.
- **Honest ceiling** (#84) — no known-sender/iMessage content, number-only calls, revocable; matches #9's page.
