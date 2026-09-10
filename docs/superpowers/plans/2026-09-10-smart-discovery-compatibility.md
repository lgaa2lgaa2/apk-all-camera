# Smart Discovery & Compatibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a unified Smart Discovery pipeline that validates real camera stream resources, classifies compatibility honestly, and feeds clear results into the add-camera flow.

**Architecture:** Add a typed compatibility result and orchestration service above the existing network, ONVIF, and RTSP probe services. Upgrade RTSP probing from server-only OPTIONS semantics to resource-level DESCRIBE semantics, then adapt the add-camera UI to consume the normalized result without changing VLC playback behavior.

**Tech Stack:** Flutter/Dart, existing socket-based discovery services, flutter_test, GitHub Actions Android build workflow

**Spec:** `docs/superpowers/specs/2026-09-10-smart-discovery-compatibility-design.md`

## Global Constraints

- Flutter Android/iOS codebase
- Preserve current premium UI style
- No false claims of proprietary cloud/P2P support
- Do not merge to `main` until explicitly approved
- `flutter analyze`, `flutter test`, and Android release APK build must all pass before considering the feature complete

---

### Task 1: Introduce typed compatibility states

**Files:**
- Create: `mobile/lib/models/discovery_compatibility.dart`
- Test: `mobile/test/discovery_compatibility_test.dart`

**Interfaces:**
- Produces: `enum DiscoveryCompatibilityStatus { compatible, authenticationRequired, partial, proprietaryUnsupported, unavailable }`
- Produces: immutable `DiscoveryCompatibilityResult` carrying host, detected services, optional validated stream, optional candidate endpoint, status, and explanation.

- [ ] **Step 1: Write the failing model tests**

Create tests that instantiate each status and verify `canPrefillStream` is true only for `compatible` with a non-empty validated stream.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile && flutter test test/discovery_compatibility_test.dart`
Expected: FAIL because the model does not exist.

- [ ] **Step 3: Implement the model**

Create focused immutable types with const constructors and derived getters only; no networking logic in the model.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile && flutter test test/discovery_compatibility_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Commit message: `feat: add discovery compatibility model`

### Task 2: Upgrade RTSP validation to DESCRIBE

**Files:**
- Modify: `mobile/lib/services/stream_validator.dart`
- Modify: `mobile/test/stream_validator_protocol_test.dart`

**Interfaces:**
- Produces: `Future<RtspValidationResult> validateRtspResource(String url)`
- Produces: `enum RtspValidationStatus { valid, authenticationRequired, unavailable }`

- [ ] **Step 1: Extend protocol tests**

Add deterministic parser tests for:
- `RTSP/1.0 200 OK` with `Content-Type: application/sdp` => valid
- `RTSP/1.0 401 Unauthorized` => authenticationRequired
- `RTSP/1.0 404 Not Found` => unavailable

- [ ] **Step 2: Run focused test and confirm failure**

Run: `cd mobile && flutter test test/stream_validator_protocol_test.dart`
Expected: FAIL because typed DESCRIBE validation is not implemented.

- [ ] **Step 3: Implement DESCRIBE request/response parsing**

Send:
`DESCRIBE <url> RTSP/1.0\r\nCSeq: 1\r\nAccept: application/sdp\r\nUser-Agent: APK-All-Camera\r\n\r\n`

Return `valid` only for a 200 response carrying SDP, `authenticationRequired` for 401, and `unavailable` otherwise.

- [ ] **Step 4: Run focused tests**

Run: `cd mobile && flutter test test/stream_validator_protocol_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Commit message: `feat: validate RTSP stream resources with DESCRIBE`

### Task 3: Build Smart Discovery orchestration

**Files:**
- Create: `mobile/lib/services/smart_discovery_service.dart`
- Modify: `mobile/lib/services/network_discovery_service.dart`
- Test: `mobile/test/smart_discovery_service_test.dart`

**Interfaces:**
- Consumes: existing LAN host/port results, ONVIF evidence, `StreamValidator.validateRtspResource`
- Produces: `Future<List<DiscoveryCompatibilityResult>> discover()`

- [ ] **Step 1: Write status-priority tests**

Cover these cases:
- validated RTSP resource => `compatible`
- 401 on a candidate => `authenticationRequired`
- camera ports with no usable stream => `partial`
- no camera service => `unavailable`

- [ ] **Step 2: Run focused tests and confirm failure**

Run: `cd mobile && flutter test test/smart_discovery_service_test.dart`
Expected: FAIL because the service does not exist.

- [ ] **Step 3: Implement orchestration**

Normalize each host into one result. Apply priority: `compatible` > `authenticationRequired` > `partial` > `proprietaryUnsupported` > `unavailable`. Preserve detected service evidence and never assign a validated URL without a successful DESCRIBE result.

- [ ] **Step 4: Run focused tests**

Run: `cd mobile && flutter test test/smart_discovery_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Commit message: `feat: add smart camera discovery orchestration`

### Task 4: Integrate ONVIF evidence into normalized results

**Files:**
- Modify: `mobile/lib/services/smart_discovery_service.dart`
- Modify: `mobile/lib/services/onvif_discovery.dart`
- Modify: `mobile/test/onvif_discovery_test.dart`
- Modify: `mobile/test/smart_discovery_service_test.dart`

**Interfaces:**
- Consumes: ONVIF XAddr probe matches
- Produces: normalized detected service evidence such as `ONVIF` and endpoint hints without claiming full media-profile support.

- [ ] **Step 1: Add tests for ONVIF-only devices**

Verify ONVIF discovery without a validated RTSP stream produces `partial`, not `compatible`.

- [ ] **Step 2: Run tests and confirm failure**

Run: `cd mobile && flutter test test/onvif_discovery_test.dart test/smart_discovery_service_test.dart`
Expected: FAIL on the new expectations.

- [ ] **Step 3: Normalize ONVIF evidence**

Expose unique XAddr endpoints and merge them into the smart-discovery result while preserving honest status semantics.

- [ ] **Step 4: Run focused tests**

Run: `cd mobile && flutter test test/onvif_discovery_test.dart test/smart_discovery_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Commit message: `feat: include ONVIF evidence in smart discovery`

### Task 5: Adapt Add Camera UI to compatibility results

**Files:**
- Modify: `mobile/lib/screens/add_camera_screen.dart`
- Modify: `mobile/test/premium_add_camera_test.dart`

**Interfaces:**
- Consumes: `DiscoveryCompatibilityResult`
- Produces: status labels, explanations, and safe form-prefill behavior.

- [ ] **Step 1: Add widget tests for all user-facing states**

Verify labels for `Compatible`, `Authentification requise`, `Partiel`, `Propriétaire/non pris en charge`, and `Indisponible`. Verify only `compatible` auto-fills a validated stream URL.

- [ ] **Step 2: Run widget test and confirm failure**

Run: `cd mobile && flutter test test/premium_add_camera_test.dart`
Expected: FAIL because the UI still uses the old discovery structure.

- [ ] **Step 3: Implement UI mapping**

Render host, services, status, explanation, and optional validated stream. Keep manual setup available for partial/proprietary cases. Never display a guessed RTSP path as validated.

- [ ] **Step 4: Run widget test**

Run: `cd mobile && flutter test test/premium_add_camera_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Commit message: `feat: show smart compatibility in add camera flow`

### Task 6: Full verification and APK build

**Files:**
- Modify only if verification exposes defects directly caused by Tasks 1-5.

**Interfaces:**
- Produces: a green feature branch workflow and release APK artifact.

- [ ] **Step 1: Run analyzer**

Run: `cd mobile && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run full tests**

Run: `cd mobile && flutter test`
Expected: all tests pass.

- [ ] **Step 3: Build release APK**

Run: `cd mobile && flutter build apk --release`
Expected: release APK generated successfully.

- [ ] **Step 4: Push final feature commits**

Push only to `feature/premium-ui-auto-discovery`.

- [ ] **Step 5: Verify GitHub Actions**

Confirm Analyze, Tests, Build release APK, Rename APK, and Upload artifact all succeed for the latest feature-branch SHA.
