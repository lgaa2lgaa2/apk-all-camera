import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/services/network_discovery_service.dart';

void main() {
  test('builds common RTSP candidates for discovered camera host', () {
    final service = NetworkDiscoveryService();
    final candidates = service.buildRtspCandidates('192.168.1.50');

    expect(candidates, contains('rtsp://192.168.1.50:554/stream1'));
    expect(candidates, contains('rtsp://192.168.1.50:554/live/ch00_0'));
    expect(candidates, contains('rtsp://192.168.1.50:554/h264Preview_01_main'));
  });

  test('recognizes common camera service ports', () {
    final service = NetworkDiscoveryService();
    expect(service.commonPorts, containsAll(<int>[80, 554, 8000, 8080, 8899]));
  });
}
