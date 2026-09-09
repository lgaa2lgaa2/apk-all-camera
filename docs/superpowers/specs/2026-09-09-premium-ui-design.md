# APK All Camera — Premium UI Design

## Goal
Reproduce the approved interactive HTML mockup as the visual and navigation reference for the Flutter application, keeping the current camera functionality while adding the new screens and setup methods.

## Visual system
- Primary palette: midnight navy, electric blue, cyan, white.
- Material 3, dark-first visual language with rounded cards, subtle gradients, thin borders and compact status chips.
- Consistent spacing, typography and iconography across Android and iOS.
- Responsive layout: phone-first with adaptive two-column/tablet layouts where space permits.

## Navigation
Primary destinations exposed from the app shell:
1. Dashboard
2. Cameras
3. Add camera
4. Alerts
5. Storage
6. Users
7. Settings

Secondary screens reached from the relevant section:
- QR setup
- Acoustic / bip-bip setup
- Bluetooth setup
- Wi-Fi AP setup
- ONVIF / RTSP discovery
- Manual camera setup
- Live view
- Multi-camera mosaic
- Event history
- Permissions
- Compatibility
- Sessions
- Admin panel
- System status
- APK / TestFlight distribution information

## Screen requirements
### Dashboard
KPI cards for cameras, alerts, storage and users, plus camera cards showing name, family, transport and online state.

### Cameras
List/grid of saved cameras with status, family, location and actions to open live view or remove a device.

### Add Camera
Method cards for QR, acoustic/bip-bip, Bluetooth, Wi-Fi AP, ONVIF/RTSP discovery and manual entry.

### Setup methods
Each method has a dedicated page with progress/status affordances. Proprietary QR/acoustic/Bluetooth behavior must be explicitly labeled as requiring a compatible vendor protocol/SDK where applicable.

### Live view
Large player, connection status, stream quality, storage info and action controls for listening, talk, snapshot, recording, PTZ and fullscreen.

### Mosaic
2x2 multi-camera visual grid, expandable later to adaptive layouts.

### Alerts and events
Configurable alert types and recent events. Visual types include motion, person, vehicle, animal, offline and storage issues.

### Storage
Cards for microSD, NAS, cloud, phone and NVR. microSD formatting remains permission-restricted and must require confirmation in the real implementation.

### Users and permissions
Admin view of users, access status, temporary access and per-camera capabilities.

### Compatibility
Vendor/family catalog with statuses Compatible, Partial, Connector Required and Untested. Proprietary support must not be represented as implemented unless it actually exists.

### Sessions
Connected devices and manual session disconnect actions. Password reset must not automatically revoke active sessions.

### Settings
Video quality, mobile-data use, biometrics option, security status and general app preferences.

### Admin and system status
Admin KPIs and management shortcuts, plus API/database/notification/VPS status placeholders wired later to backend APIs.

## Architecture
- Central AppTheme owns colors, typography, card/input/button themes.
- AppShell owns bottom navigation and top-level section switching.
- Each page is a focused widget in `mobile/lib/screens`.
- Reusable UI widgets live in `mobile/lib/widgets`.
- Existing camera model, registry, compatibility catalog and player functionality are reused rather than duplicated.

## Testing
- Widget tests for app shell navigation and visible destination labels.
- Widget tests for Add Camera method cards including acoustic/bip-bip.
- Existing camera model tests remain green.
- GitHub Actions must run `flutter test` before release APK build.

## Non-goals for this UI pass
- Implementing unknown proprietary vendor cloud/P2P protocols.
- Pretending acoustic provisioning works for every camera family.
- Implementing full backend/admin APIs in the mobile UI layer.
