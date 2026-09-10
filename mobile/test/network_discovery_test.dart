import 'package:flutter_test/flutter_test.dart';
import 'package:apk_all_camera/services/network_discovery.dart';

void main() {
  test('common camera ports include ONVIF and RTSP defaults', () {
    expect(NetworkDiscovery.commonPorts, containsAll(<int>[80, 554, 8000, 8080, 8899]));
  });

  test('rtsp candidates include common vendor paths', () {
    final candidates = NetworkDiscovery.rtspCandidates('192.168.1.50', 554);
    expect(candidates, contains('rtsp://192.168.1.50:554/stream1'));
    expect(candidates, contains('rtsp://192.168.1.50:554/Streaming/Channels/101'));
    expect(candidates, contains('rtsp://192.168.1.50:554/cam/realmonitor?channel=1&subtype=0'));
  });

  test('private ipv4 detection accepts RFC1918 ranges', () {
    expect(NetworkDiscovery.isPrivateIpv4('192.168.1.10'), isTrue);
    expect(NetworkDiscovery.isPrivateIpv4('10.0.0.2'), isTrue);
    expect(NetworkDiscovery.isPrivateIpv4('172.16.0.5'), isTrue);
    expect(NetworkDiscovery.isPrivateIpv4('8.8.8.8'), isFalse);
  });
}
