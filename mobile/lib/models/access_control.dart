enum UserRole { admin, user }

class CameraPermissions {
  const CameraPermissions({
    required this.liveView,
    required this.ptz,
    required this.audio,
    required this.recordings,
    required this.alerts,
    required this.manageStorage,
    required this.manageUsers,
  });

  final bool liveView;
  final bool ptz;
  final bool audio;
  final bool recordings;
  final bool alerts;
  final bool manageStorage;
  final bool manageUsers;

  static const admin = CameraPermissions(
    liveView: true,
    ptz: true,
    audio: true,
    recordings: true,
    alerts: true,
    manageStorage: true,
    manageUsers: true,
  );

  static const viewer = CameraPermissions(
    liveView: true,
    ptz: false,
    audio: true,
    recordings: true,
    alerts: true,
    manageStorage: false,
    manageUsers: false,
  );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.cameraIds,
    this.customPermissions,
    this.accessStartsAt,
    this.accessEndsAt,
    this.suspended = false,
  });

  final String id;
  final String name;
  final UserRole role;
  final List<String> cameraIds;
  final CameraPermissions? customPermissions;
  final DateTime? accessStartsAt;
  final DateTime? accessEndsAt;
  final bool suspended;

  CameraPermissions get permissions => role == UserRole.admin
      ? CameraPermissions.admin
      : (customPermissions ?? CameraPermissions.viewer);

  bool canAccessCamera(String cameraId, {DateTime? now}) {
    if (suspended) return false;
    if (role == UserRole.admin) return true;
    final current = now ?? DateTime.now();
    if (accessStartsAt != null && current.isBefore(accessStartsAt!)) return false;
    if (accessEndsAt != null && current.isAfter(accessEndsAt!)) return false;
    return cameraIds.contains(cameraId);
  }
}
