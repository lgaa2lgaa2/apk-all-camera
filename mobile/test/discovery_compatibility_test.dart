import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/discovery_compatibility.dart';

void main() {
  test('compatible result can prefill a validated stream', () {
    const result = DiscoveryCompatibilityResult(
      host: '192.168.1.10',
      detectedServices: ['RTSP'],
      validatedStream: 'rtsp://192.168.1.10:554/stream1',
      candidateEndpoint: 'rtsp://192.168.1.10:554/stream1',
      status: DiscoveryCompatibilityStatus.compatible,
      explanation: 'Validated RTSP stream.',
    );

    expect(result.canPrefillStream, isTrue);
  });

  test('non-compatible results never prefill a stream', () {
    for (final status in DiscoveryCompatibilityStatus.values) {
      if (status == DiscoveryCompatibilityStatus.compatible) continue;
      final result = DiscoveryCompatibilityResult(
        host: '192.168.1.10',
        detectedServices: const ['RTSP'],
        validatedStream: 'rtsp://192.168.1.10:554/stream1',
        status: status,
        explanation: 'Not fully validated.',
      );
      expect(result.canPrefillStream, isFalse, reason: status.name);
    }
  });

  test('compatible result without validated stream cannot prefill', () {
    const result = DiscoveryCompatibilityResult(
      host: '192.168.1.10',
      detectedServices: ['RTSP'],
      status: DiscoveryCompatibilityStatus.compatible,
      explanation: 'Missing validated stream.',
    );

    expect(result.canPrefillStream, isFalse);
  });
}
