import 'package:apk_all_camera/models/discovery_compatibility.dart';
import 'package:apk_all_camera/services/network_discovery_service.dart';
import 'package:apk_all_camera/services/onvif_discovery.dart';
import 'package:apk_all_camera/services/smart_discovery_service.dart';
import 'package:apk_all_camera/services/stream_validator.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNetworkDiscoveryService extends NetworkDiscoveryService {
  _FakeNetworkDiscoveryService(this.results);

  final List<DiscoveredCamera> results;

  @override
  Future<List<DiscoveredCamera>> scanLocalSubnet({
    Duration timeout = const Duration(milliseconds: 120),
    int concurrency = 32,
  }) async => results;
}

class _FakeOnvifDiscovery extends OnvifDiscovery {
  const _FakeOnvifDiscovery(this.results);

  final List<OnvifProbeResult> results;

  @override
  Future<List<OnvifProbeResult>> discover({
    Duration timeout = const Duration(seconds: 3),
  }) async => results;
}

class _FakeStreamValidator extends StreamValidator {
  const _FakeStreamValidator(this.statuses);

  final Map<String, RtspValidationStatus> statuses;

  @override
  Future<RtspValidationResult> validateRtspResource(
    String url, {
    Duration timeout = const Duration(milliseconds: 900),
  }) async => RtspValidationResult(
        status: statuses[url] ?? RtspValidationStatus.unavailable,
        url: url,
      );
}

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

  test('maps discovered camera into smart discovery evidence', () {
    final camera = DiscoveredCamera(
      host: '192.168.1.30',
      openPorts: <int>[80, 554],
      streamCandidates: <String>['rtsp://192.168.1.30:554/stream1'],
      validatedStream: 'rtsp://192.168.1.30:554/stream1',
    );

    final result = SmartDiscoveryService.fromDiscoveredCamera(camera);

    expect(result.status, DiscoveryCompatibilityStatus.compatible);
    expect(result.detectedServices, containsAll(<String>['HTTP', 'RTSP']));
    expect(result.validatedStream, camera.validatedStream);
  });

  test('discover merges ONVIF evidence and reports RTSP authentication requirement', () async {
    const stream = 'rtsp://192.168.1.40:554/stream1';
    final service = SmartDiscoveryService(
      networkDiscovery: _FakeNetworkDiscoveryService(<DiscoveredCamera>[
        const DiscoveredCamera(
          host: '192.168.1.40',
          openPorts: <int>[554],
          streamCandidates: <String>[stream],
        ),
      ]),
      onvifDiscovery: const _FakeOnvifDiscovery(<OnvifProbeResult>[
        OnvifProbeResult(
          xaddr: 'http://192.168.1.40/onvif/device_service',
          host: '192.168.1.40',
        ),
      ]),
      streamValidator: const _FakeStreamValidator(<String, RtspValidationStatus>{
        stream: RtspValidationStatus.authenticationRequired,
      }),
    );

    final results = await service.discover();

    expect(results, hasLength(1));
    expect(results.single.detectedServices, containsAll(<String>['ONVIF', 'RTSP']));
    expect(
      results.single.status,
      DiscoveryCompatibilityStatus.authenticationRequired,
    );
    expect(results.single.candidateEndpoint, stream);
    expect(results.single.validatedStream, isNull);
  });
}
