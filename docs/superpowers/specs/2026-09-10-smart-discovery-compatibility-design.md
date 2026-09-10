# Smart Discovery & Compatibility Design

## Goal
Build a differentiated camera onboarding subsystem for APK All Camera that automatically discovers cameras, validates real stream capability, identifies likely protocol/family support, and presents a clear compatibility result instead of pretending unsupported proprietary integrations work.

## Product promise
The user should be able to tap “Ajouter une caméra”, let the app scan, and get an understandable answer: what was found, what works, what still needs credentials, and what is proprietary/unsupported.

## Scope
This subsystem covers local-network discovery and capability classification. It does not claim support for proprietary vendor clouds/SDKs unless those integrations are separately implemented and tested.

## Architecture
Create a single Smart Discovery orchestration layer that combines existing network port scanning, ONVIF discovery, RTSP candidate generation, and RTSP resource validation. Keep protocol probes separate from UI code so discovery logic can evolve independently.

The orchestration result is a typed compatibility report consumed by the add-camera flow. UI only pre-fills a stream URL when a specific RTSP resource has been validated.

## Components

### 1. Smart discovery orchestrator
A focused service coordinates:
- LAN host/port discovery
- ONVIF WS-Discovery results
- common RTSP path candidates
- resource-level RTSP validation
- family hints inferred from protocols/ports/known path patterns

It returns a normalized list of camera candidates.

### 2. Compatibility status model
Each candidate has one primary status:
- `compatible`: a concrete stream/resource was validated and can be used now
- `authenticationRequired`: an RTSP/ONVIF endpoint responded but credentials are required
- `partial`: camera-like services are present, but no playable stream was validated
- `proprietaryUnsupported`: strong evidence points to a vendor-specific/proprietary path that the app does not implement
- `unavailable`: discovery found a host but no usable camera service

The UI must never label an endpoint “validated” from a generic RTSP server response alone.

### 3. RTSP validation
Replace server-only `OPTIONS` semantics with resource-level `DESCRIBE` semantics for stream candidates.

Interpretation:
- RTSP 200 with SDP response => validated stream
- RTSP 401 => authentication required
- timeout/refused/404/other unusable response => not validated

No credential guessing or brute force.

### 4. ONVIF integration
Reuse the existing WS-Discovery probe and normalize discovered XAddr endpoints into the smart-discovery result. This phase does not yet require full GetProfiles/GetStreamUri media negotiation; it records ONVIF evidence and capability state honestly.

### 5. Add-camera UX
The automatic-discovery section shows for each candidate:
- IP/host
- detected protocols/services
- compatibility status
- short human-readable explanation
- validated stream URL only when available

Selecting a compatible candidate pre-fills the add-camera form. Selecting an authentication-required candidate pre-fills the endpoint and asks for credentials. Partial/proprietary candidates remain selectable for manual setup but are not presented as fully compatible.

## Error handling
Discovery failures are per-host/per-protocol and must not abort the whole scan. Timeouts yield partial/unavailable states, not crashes. Unsupported proprietary families produce explicit explanatory copy.

## Testing
Add deterministic unit tests for:
- RTSP 200 + SDP => compatible
- RTSP 401 => authentication required
- RTSP 404/timeout => not validated
- status prioritization when multiple probes disagree
- no stream prefill unless resource-level validation succeeds
- add-camera UI labels for each compatibility state

Existing widget tests must remain isolated from native VLC initialization.

## Constraints
- Flutter Android/iOS codebase
- Preserve current premium UI style
- No false claims of proprietary cloud/P2P support
- Do not merge to `main` until explicitly approved
- `flutter analyze`, `flutter test`, and Android release APK build must all pass before considering the feature complete
