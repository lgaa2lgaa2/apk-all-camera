import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/access_control.dart';

void main() {
  test('admin has all permissions', () {
    const user = AppUser(id: '1', name: 'Admin', role: UserRole.admin, cameraIds: <String>[]);
    expect(user.permissions.liveView, isTrue);
    expect(user.permissions.ptz, isTrue);
    expect(user.permissions.manageStorage, isTrue);
    expect(user.permissions.manageUsers, isTrue);
  });

  test('viewer permissions can be restricted per feature', () {
    const permissions = CameraPermissions(liveView: true, ptz: false, audio: false, recordings: true, alerts: true, manageStorage: false, manageUsers: false);
    const user = AppUser(id: '2', name: 'User', role: UserRole.user, cameraIds: <String>['cam1'], customPermissions: permissions);
    expect(user.permissions.liveView, isTrue);
    expect(user.permissions.ptz, isFalse);
    expect(user.cameraIds, contains('cam1'));
  });
}
