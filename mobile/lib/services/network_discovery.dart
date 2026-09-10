import 'dart:async';
import 'dart:io';

class DiscoveredCamera {
  const DiscoveredCamera({
    required this.host,
    required this.openPorts,
    required this.rtspCandidates,
  });

  final String host;
  final List<int> openPorts;
  final List<String> rtspCandidates;

  bool get hasRtsp => openPorts.contains(554);
  bool get hasHttp => openPorts.contains(80) || openPorts.contains(8080);
}

class NetworkDiscovery {
  const NetworkDiscovery();

  static const List<int> commonPorts = <int>[80, 554, 8000, 8080, 8899];

  static bool isPrivateIpv4(String address) {
    final parts = address.split('.').map(int.tryParse).toList();
    if (parts.length != 4 || parts.any((p) => p == null || p < 0 || p > 255)) {
      return false;
    }
    final a = parts[0]!;
    final b = parts[1]!;
    if (a == 10) return true;
    if (a == 192 && b == 168) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    return false;
  }

  static List<String> rtspCandidates(String host, int port) => <String>[
        'rtsp://$host:$port/stream1',
        'rtsp://$host:$port/stream2',
        'rtsp://$host:$port/live/ch00_0',
        'rtsp://$host:$port/live/ch00_1',
        'rtsp://$host:$port/Streaming/Channels/101',
        'rtsp://$host:$port/Streaming/Channels/102',
        'rtsp://$host:$port/cam/realmonitor?channel=1&subtype=0',
        'rtsp://$host:$port/cam/realmonitor?channel=1&subtype=1',
        'rtsp://$host:$port/h264Preview_01_main',
        'rtsp://$host:$port/h264Preview_01_sub',
      ];

  Future<String?> localIpv4() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLoopback: false);
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (isPrivateIpv4(address.address)) return address.address;
      }
    }
    return null;
  }

  Future<bool> isPortOpen(String host, int port, {Duration timeout = const Duration(milliseconds: 250)}) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port, timeout: timeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  Future<List<DiscoveredCamera>> scanLocalSubnet({
    Duration timeout = const Duration(milliseconds: 250),
    int concurrency = 32,
  }) async {
    final local = await localIpv4();
    if (local == null) return const [];
    final parts = local.split('.');
    if (parts.length != 4) return const [];
    final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
    final queue = List<int>.generate(254, (index) => index + 1);
    final results = <DiscoveredCamera>[];
    var cursor = 0;

    Future<void> worker() async {
      while (true) {
        final index = cursor++;
        if (index >= queue.length) return;
        final host = '$prefix.${queue[index]}';
        if (host == local) continue;

        final openPorts = <int>[];
        for (final port in commonPorts) {
          if (await isPortOpen(host, port, timeout: timeout)) {
            openPorts.add(port);
          }
        }
        if (openPorts.isEmpty) continue;
        results.add(
          DiscoveredCamera(
            host: host,
            openPorts: openPorts,
            rtspCandidates: openPorts.contains(554) ? rtspCandidates(host, 554) : const [],
          ),
        );
      }
    }

    await Future.wait(List<Future<void>>.generate(concurrency, (_) => worker()));
    results.sort((a, b) => a.host.compareTo(b.host));
    return results;
  }
}
