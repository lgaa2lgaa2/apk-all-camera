import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/services/onvif_discovery.dart';

void main() {
  test('parses ONVIF probe match xaddr', () {
    const xml = '<Envelope><Body><ProbeMatches><ProbeMatch><XAddrs>http://192.168.1.25:80/onvif/device_service</XAddrs></ProbeMatch></ProbeMatches></Body></Envelope>';
    final matches = OnvifDiscovery.parseProbeMatches(xml);
    expect(matches, contains('http://192.168.1.25:80/onvif/device_service'));
  });

  test('builds digest-safe stream candidates', () {
    final streams = OnvifDiscovery.fallbackRtspCandidates('192.168.1.25');
    expect(streams.first, startsWith('rtsp://192.168.1.25:554/'));
    expect(streams, contains('rtsp://192.168.1.25:554/Streaming/Channels/101'));
  });
}
