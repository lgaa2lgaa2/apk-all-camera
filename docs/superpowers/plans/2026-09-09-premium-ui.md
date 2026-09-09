# Premium UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild APK All Camera’s Flutter interface to match the approved premium HTML mockup across all main and secondary pages while preserving current camera functionality.

**Architecture:** Introduce a centralized dark premium theme, a reusable application shell, focused page widgets, and shared UI components. Existing camera models, registry, compatibility data, and video player logic remain the source of truth; new pages compose around them rather than duplicating behavior.

**Tech Stack:** Flutter 3.x, Dart 3.x, Material 3, existing `flutter_vlc_player`, existing local persistence.

**Spec:** `docs/superpowers/specs/2026-09-09-premium-ui-design.md`

## Global Constraints

- Match the approved palette: midnight navy, electric blue, cyan, white.
- Keep Material 3.
- Do not claim proprietary camera/cloud/acoustic compatibility unless implemented.
- Keep current camera add/save/live behavior working.
- Password reset must not automatically revoke active sessions.
- `flutter test` must pass before release APK build.

---

### Task 1: Theme system and shell

**Files:**
- Create: `mobile/lib/theme/app_theme.dart`
- Create: `mobile/lib/widgets/app_shell.dart`
- Modify: `mobile/lib/main.dart`
- Test: `mobile/test/app_shell_test.dart`

**Interfaces:**
- Produces: `AppTheme.dark()`, `AppShell` with destination index switching.

- [ ] **Step 1: Write the failing shell navigation test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/widgets/app_shell.dart';

void main() {
  testWidgets('shell exposes primary destinations', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    expect(find.text('Caméras'), findsWidgets);
    expect(find.text('Ajouter'), findsWidgets);
    expect(find.text('Alertes'), findsWidgets);
    expect(find.text('Stockage'), findsWidgets);
    expect(find.text('Utilisateurs'), findsWidgets);
    expect(find.text('Réglages'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run the test and verify RED**

Run: `cd mobile && flutter test test/app_shell_test.dart`
Expected: FAIL because `AppShell` does not exist.

- [ ] **Step 3: Implement `AppTheme` and `AppShell`**

Create a dark Material 3 theme with navy background, blue/cyan accents, rounded cards and inputs. Implement a responsive shell with bottom navigation on phone and navigation rail on wider layouts.

- [ ] **Step 4: Wire `main.dart` to the new theme and shell**

Replace the current seed-color theme with `AppTheme.dark()` and set `home: const AppShell()`.

- [ ] **Step 5: Run the test and verify GREEN**

Run: `cd mobile && flutter test test/app_shell_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/theme/app_theme.dart mobile/lib/widgets/app_shell.dart mobile/lib/main.dart mobile/test/app_shell_test.dart
git commit -m "feat: add premium app theme and navigation shell"
```

### Task 2: Dashboard and camera cards

**Files:**
- Create: `mobile/lib/screens/dashboard_screen.dart`
- Create: `mobile/lib/widgets/stat_card.dart`
- Create: `mobile/lib/widgets/camera_card.dart`
- Modify: `mobile/lib/widgets/app_shell.dart`
- Test: `mobile/test/dashboard_screen_test.dart`

**Interfaces:**
- Consumes: existing `CameraRegistry` and `CameraDevice`.
- Produces: dashboard KPI cards and camera grid/list.

- [ ] **Step 1: Write a failing dashboard widget test**

Verify the screen renders labels `Caméras`, `Alertes`, `Stockage`, and `Utilisateurs`.

- [ ] **Step 2: Run test and verify RED**

Run: `cd mobile && flutter test test/dashboard_screen_test.dart`
Expected: FAIL because the dashboard widget does not exist.

- [ ] **Step 3: Implement reusable stat and camera cards**

Cards must use the theme’s dark surfaces, subtle borders, rounded corners, online/offline chips, camera family and location metadata.

- [ ] **Step 4: Implement dashboard**

Load cameras from `CameraRegistry`, show KPI cards and camera cards. Opening a camera navigates to the existing live player.

- [ ] **Step 5: Run test and verify GREEN**

Run: `cd mobile && flutter test test/dashboard_screen_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/screens/dashboard_screen.dart mobile/lib/widgets/stat_card.dart mobile/lib/widgets/camera_card.dart mobile/lib/widgets/app_shell.dart mobile/test/dashboard_screen_test.dart
git commit -m "feat: add premium dashboard and camera cards"
```

### Task 3: Add-camera hub and setup method pages

**Files:**
- Modify: `mobile/lib/screens/add_camera_screen.dart`
- Create: `mobile/lib/screens/setup_method_screen.dart`
- Create: `mobile/lib/widgets/setup_method_card.dart`
- Test: `mobile/test/add_camera_methods_test.dart`

**Interfaces:**
- Produces: visible method cards for QR, acoustic/bip-bip, Bluetooth, Wi-Fi AP, ONVIF/RTSP discovery and manual setup.

- [ ] **Step 1: Write the failing methods test**

```dart
expect(find.text('QR code'), findsOneWidget);
expect(find.text('Son / bip-bip'), findsOneWidget);
expect(find.text('Bluetooth'), findsOneWidget);
expect(find.text('Wi-Fi AP'), findsOneWidget);
expect(find.text('ONVIF / RTSP'), findsOneWidget);
expect(find.text('Ajout manuel'), findsOneWidget);
```

- [ ] **Step 2: Run test and verify RED**

Run: `cd mobile && flutter test test/add_camera_methods_test.dart`
Expected: FAIL until the redesigned hub is implemented.

- [ ] **Step 3: Implement the method-card grid**

Each card includes icon, title, concise description and navigation to a dedicated setup page.

- [ ] **Step 4: Implement setup method pages**

Provide dedicated UI for QR, acoustic, Bluetooth, Wi-Fi AP and ONVIF discovery. Acoustic screen must explicitly state that vendor protocol/SDK compatibility is required.

- [ ] **Step 5: Keep manual camera creation functional**

Retain the current camera form and return a `CameraDevice` to the caller so existing persistence continues to work.

- [ ] **Step 6: Run test and verify GREEN**

Run: `cd mobile && flutter test test/add_camera_methods_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/screens/add_camera_screen.dart mobile/lib/screens/setup_method_screen.dart mobile/lib/widgets/setup_method_card.dart mobile/test/add_camera_methods_test.dart
git commit -m "feat: redesign camera setup flows"
```

### Task 4: Live view and mosaic

**Files:**
- Modify: `mobile/lib/screens/player_screen.dart`
- Create: `mobile/lib/screens/mosaic_screen.dart`
- Create: `mobile/lib/widgets/live_control_button.dart`
- Test: `mobile/test/live_controls_test.dart`

**Interfaces:**
- Consumes: current `VlcPlayerController`/stream behavior.
- Produces: premium live screen with control bar and 2x2 mosaic screen.

- [ ] **Step 1: Write a failing controls test**

Verify labels `Écouter`, `Parler`, `Photo`, `REC`, `PTZ`, `Plein écran` are present.

- [ ] **Step 2: Run RED test**

Run: `cd mobile && flutter test test/live_controls_test.dart`
Expected: FAIL before UI redesign.

- [ ] **Step 3: Redesign player without changing stream semantics**

Keep VLC stream initialization intact. Wrap player in premium card, add status metadata and control buttons.

- [ ] **Step 4: Add mosaic screen**

Render up to four saved cameras in a 2x2 visual layout; use placeholders where simultaneous playback is not initialized.

- [ ] **Step 5: Run GREEN test**

Run: `cd mobile && flutter test test/live_controls_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/screens/player_screen.dart mobile/lib/screens/mosaic_screen.dart mobile/lib/widgets/live_control_button.dart mobile/test/live_controls_test.dart
git commit -m "feat: redesign live view and add mosaic screen"
```

### Task 5: Alerts, events and storage

**Files:**
- Create: `mobile/lib/screens/alerts_screen.dart`
- Create: `mobile/lib/screens/events_screen.dart`
- Create: `mobile/lib/screens/storage_screen.dart`
- Modify: `mobile/lib/widgets/app_shell.dart`
- Test: `mobile/test/operations_screens_test.dart`

**Interfaces:**
- Produces: premium alert configuration, event history and storage destination views.

- [ ] **Step 1: Write failing screen-presence tests**

Verify alert labels include `Personne`, `Véhicule`, `Animal`, `Hors ligne`; storage includes `microSD`, `NAS`, `Cloud`, `Téléphone`, `NVR`.

- [ ] **Step 2: Run RED test**

Run: `cd mobile && flutter test test/operations_screens_test.dart`
Expected: FAIL because screens do not exist.

- [ ] **Step 3: Implement alerts and event history**

Use premium cards, toggles and status chips. Data may remain local/demo until backend APIs exist.

- [ ] **Step 4: Implement storage screen**

Represent SD/NAS/cloud/phone/NVR; SD format button must show a confirmation dialog and be clearly privileged.

- [ ] **Step 5: Run GREEN test**

Run: `cd mobile && flutter test test/operations_screens_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/screens/alerts_screen.dart mobile/lib/screens/events_screen.dart mobile/lib/screens/storage_screen.dart mobile/lib/widgets/app_shell.dart mobile/test/operations_screens_test.dart
git commit -m "feat: add alerts events and storage screens"
```

### Task 6: Users, permissions, compatibility and sessions

**Files:**
- Create: `mobile/lib/screens/users_screen.dart`
- Create: `mobile/lib/screens/permissions_screen.dart`
- Modify: `mobile/lib/screens/compatibility_screen.dart`
- Create: `mobile/lib/screens/sessions_screen.dart`
- Test: `mobile/test/access_screens_test.dart`

**Interfaces:**
- Consumes: existing compatibility catalog.
- Produces: user/access/session presentation screens.

- [ ] **Step 1: Write failing tests**

Verify `Administrateur`, `Accès temporaire`, `Caméras autorisées`, `Droits`, `Compatible`, `Partiel`, and `Déconnecter` appear in the relevant screens.

- [ ] **Step 2: Run RED test**

Run: `cd mobile && flutter test test/access_screens_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement user and permission cards**

Use demo data structures isolated from future backend integration; do not alter authentication semantics.

- [ ] **Step 4: Redesign compatibility screen using real catalog entries**

Map catalog capabilities into premium cards and honest status labels.

- [ ] **Step 5: Implement sessions screen**

Show current and previous devices with manual disconnect actions only; no automatic revocation behavior.

- [ ] **Step 6: Run GREEN test**

Run: `cd mobile && flutter test test/access_screens_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add mobile/lib/screens/users_screen.dart mobile/lib/screens/permissions_screen.dart mobile/lib/screens/compatibility_screen.dart mobile/lib/screens/sessions_screen.dart mobile/test/access_screens_test.dart
git commit -m "feat: add premium access and compatibility screens"
```

### Task 7: Settings, admin, system and distribution screens

**Files:**
- Create: `mobile/lib/screens/settings_screen.dart`
- Create: `mobile/lib/screens/admin_screen.dart`
- Create: `mobile/lib/screens/system_status_screen.dart`
- Create: `mobile/lib/screens/distribution_screen.dart`
- Modify: `mobile/lib/widgets/app_shell.dart`
- Test: `mobile/test/admin_screens_test.dart`

**Interfaces:**
- Produces: final secondary screens from the approved mockup.

- [ ] **Step 1: Write failing tests**

Verify `Vidéo sur 4G/5G`, `HTTPS / TLS`, `Panel Admin`, `État système`, `Android`, and `iPhone` labels.

- [ ] **Step 2: Run RED test**

Run: `cd mobile && flutter test test/admin_screens_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement settings and admin screens**

Use local/demo values and clean section cards. Clearly label backend-dependent status values as placeholders until connected.

- [ ] **Step 4: Implement system and distribution screens**

Show API/database/notifications status placeholders and Android APK/TestFlight distribution information.

- [ ] **Step 5: Run GREEN test**

Run: `cd mobile && flutter test test/admin_screens_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/screens/settings_screen.dart mobile/lib/screens/admin_screen.dart mobile/lib/screens/system_status_screen.dart mobile/lib/screens/distribution_screen.dart mobile/lib/widgets/app_shell.dart mobile/test/admin_screens_test.dart
git commit -m "feat: add settings admin system and distribution screens"
```

### Task 8: Full verification and APK build

**Files:**
- Modify only if required by test/build failures.

**Interfaces:**
- Produces: verified green build and GitHub Actions artifact.

- [ ] **Step 1: Run the full Flutter test suite**

Run: `cd mobile && flutter test`
Expected: all tests PASS.

- [ ] **Step 2: Run static analysis**

Run: `cd mobile && flutter analyze`
Expected: no errors.

- [ ] **Step 3: Build Android release locally if SDK is available**

Run: `cd mobile && flutter build apk --release`
Expected: `build/app/outputs/flutter-apk/app-release.apk`.

- [ ] **Step 4: Push to `main` and verify GitHub Actions**

Expected workflow: `Build Android APK` completes successfully and uploads artifact `APK-All-Camera`.

- [ ] **Step 5: Commit any verification-only fixes**

```bash
git add mobile
git commit -m "fix: resolve premium UI verification issues"
```

## Self-review

- Spec coverage: all approved mockup destinations are represented by tasks.
- Placeholder scan: no implementation step relies on unspecified behavior; backend-only screens are explicitly local/demo placeholders.
- Type consistency: all tasks reuse existing `CameraDevice`, `CameraRegistry`, compatibility catalog, and VLC player behavior rather than introducing competing models.
