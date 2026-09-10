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
    if (parts.length != 4 || parts.any((p) => p == null || p! < 0 || p > 255)) {
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
    Duration timeout = const Duration(milliseconds: 220),
    int firstHost = 1,
    int lastHost = 254,
  }) async {
    final local = await localIpv4();
    if (local == null) return const <DiscoveredCamera>[];
    final parts = local.split('.');
    if (parts.length != 4) return const <DiscoveredCamera>[];
    final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
    final results = <DiscoveredCamera>[];

    const batchSize = 24;
    for (int start = firstHost; start <= lastHost; start += batchSize) {
      final end = (start + batchSize - 1) > lastHost ? lastHost : start + batchSize - 1;
      final hosts = <Future<DiscoveredCamera?>>[];
      for (int i = start; i <= end; i++) {
        final host = '$prefix.$i';
        if (host == local) continue;
        hosts.add(_probeHost(host, timeout));
      }
      final batch = await Future.wait(hosts);
      results.addAll(batch.whereType<DiscoveredCamera>());
    }
    return results;
  }

  Future<DiscoveredCamera?> _probeHost(String host, Duration timeout) async {
    final open = <int>[];
    final checks = await Future.wait(commonPorts.map((port) async => MapEntry(port, await isPortOpen(host, port, timeout: timeout))));
    for (final check in checks) {
      if (check.value) open.add(check.key);
    }
    if (open.isEmpty) return null;
    final rtspPort = open.contains(554) ? 554 : null;
    return DiscoveredCamera(
      host: host,
      openPorts: open,
      rtspCandidates: rtspPort == null ? const <String>[] : rtspCandidates(host, rtspPort),
    );
  }
}
