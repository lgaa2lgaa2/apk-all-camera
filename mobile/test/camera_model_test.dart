import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/camera.dart';

void main() {
  test('camera list round-trips through JSON', () {
    const camera = CameraDevice(
      id: '1',
      name: 'Entrée',
      family: 'ONVIF / RTSP',
      streamUrl: 'rtsp://10.0.0.8/live',
      connectionType: CameraConnectionType.rtsp,
      username: 'admin',
      password: 'secret',
    );

    final decoded = CameraDevice.decodeList(CameraDevice.encodeList([camera]));
    expect(decoded.single.name, 'Entrée');
    expect(decoded.single.connectionType, CameraConnectionType.rtsp);
  });

  test('authenticated uri injects encoded credentials', () {
    const camera = CameraDevice(
      id: '1',
      name: 'Test',
      family: 'ONVIF / RTSP',
      streamUrl: 'rtsp://10.0.0.8/live',
      connectionType: CameraConnectionType.rtsp,
      username: 'admin',
      password: 'p@ss',
    );
    expect(camera.authenticatedUri()?.userInfo, contains('admin'));
  });
}
