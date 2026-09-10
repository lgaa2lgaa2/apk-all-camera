import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/models/discovery_compatibility.dart';
import 'package:apk_all_camera/services/onvif_discovery.dart';
import 'package:apk_all_camera/services/smart_discovery_service.dart';

void main() {
  test('parses ONVIF probe match xaddr', () {
    const xml = '<Envelope><Body><ProbeMatches><ProbeMatch><XAddrs>http://192.168.1.25:80/onvif/device_service</XAddrs></ProbeMatch></ProbeMatches></Body></Envelope>';
    final matches = OnvifDiscovery.parseProbeMatches(xml);
    expect(matches, contains('http://192.168.1.25:80/onvif/device_service'));
  });

  test('deduplicates ONVIF xaddr values from probe matches', () {
    const xml = '<Envelope><Body><ProbeMatches>'
        '<ProbeMatch><XAddrs>http://192.168.1.25:80/onvif/device_service http://192.168.1.25:80/onvif/device_service</XAddrs></ProbeMatch>'
        '<ProbeMatch><XAddrs>http://192.168.1.25:8080/onvif/device_service</XAddrs></ProbeMatch>'
        '</ProbeMatches></Body></Envelope>';
    final matches = OnvifDiscovery.parseProbeMatches(xml);
    expect(matches, hasLength(2));
    expect(matches, contains('http://192.168.1.25:80/onvif/device_service'));
    expect(matches, contains('http://192.168.1.25:8080/onvif/device_service'));
  });

  test('builds digest-safe stream candidates', () {
    final streams = OnvifDiscovery.fallbackRtspCandidates('192.168.1.25');
    expect(streams.first, startsWith('rtsp://192.168.1.25:554/'));
    expect(streams, contains('rtsp://192.168.1.25:554/Streaming/Channels/101'));
  });

  test('ONVIF evidence without validated RTSP remains partial', () {
    final result = SmartDiscoveryService.classifyHost(
      host: '192.168.1.25',
      detectedServices: const <String>['ONVIF'],
      authenticationRequired: false,
      candidateEndpoint: 'http://192.168.1.25:80/onvif/device_service',
    );

    expect(result.status, DiscoveryCompatibilityStatus.partial);
    expect(result.validatedStream, isNull);
    expect(result.detectedServices, contains('ONVIF'));
    expect(result.candidateEndpoint, 'http://192.168.1.25:80/onvif/device_service');
  });
}
