import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/setup_method.dart';

void main() {
  test('setup methods include acoustic provisioning', () {
    expect(
      CameraSetupMethod.values,
      contains(CameraSetupMethod.acoustic),
    );
  });

  test('acoustic setup method exposes a French label', () {
    expect(CameraSetupMethod.acoustic.label, contains('Son'));
  });
}
