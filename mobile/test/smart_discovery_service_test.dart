import 'package:apk_all_camera/models/discovery_compatibility.dart';
import 'package:apk_all_camera/services/smart_discovery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validated RTSP resource is compatible', () {
    final result = SmartDiscoveryService.classifyHost(
      host: '192.168.1.20',
      detectedServices: <String>['RTSP'],
      validatedStream: 'rtsp://192.168.1.20:554/stream1',
      authenticationRequired: false,
    );

    expect(result.status, DiscoveryCompatibilityStatus.compatible);
    expect(result.validatedStream, 'rtsp://192.168.1.20:554/stream1');
  });

  test('authentication requirement has priority over partial service evidence', () {
    final result = SmartDiscoveryService.classifyHost(
      host: '192.168.1.21',
      detectedServices: <String>['RTSP', 'HTTP'],
      authenticationRequired: true,
      candidateEndpoint: 'rtsp://192.168.1.21:554/stream1',
    );

    expect(result.status, DiscoveryCompatibilityStatus.authenticationRequired);
    expect(result.validatedStream, isNull);
  });

  test('camera services without usable stream are partial', () {
    final result = SmartDiscoveryService.classifyHost(
      host: '192.168.1.22',
      detectedServices: <String>['HTTP'],
      authenticationRequired: false,
    );

    expect(result.status, DiscoveryCompatibilityStatus.partial);
  });

  test('host without camera service is unavailable', () {
    final result = SmartDiscoveryService.classifyHost(
      host: '192.168.1.23',
      detectedServices: <String>[],
      authenticationRequired: false,
    );

    expect(result.status, DiscoveryCompatibilityStatus.unavailable);
  });
}
