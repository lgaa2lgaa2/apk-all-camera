import 'dart:async';
import 'dart:io';

class DiscoveredCamera {
  const DiscoveredCamera({
    required this.host,
    required this.openPorts,
    required this.streamCandidates,
  });

  final String host;
  final List<int> openPorts;
  final List<String> streamCandidates;

  String get bestStream => streamCandidates.isNotEmpty ? streamCandidates.first : '';
}

class NetworkDiscoveryService {
  static const List<int> defaultPorts = <int>[80, 554, 8000, 8080, 8899];

  List<int> get commonPorts => defaultPorts;

  List<String> buildRtspCandidates(String host) => <String>[
        'rtsp://$host:554/stream1',
        'rtsp://$host:554/live/ch00_0',
        'rtsp://$host:554/h264Preview_01_main',
        'rtsp://$host:554/cam/realmonitor?channel=1&subtype=0',
        'rtsp://$host:554/Streaming/Channels/101',
      ];

  Future<List<DiscoveredCamera>> scanLocalSubnet({
    Duration timeout = const Duration(milliseconds: 120),
    int concurrency = 32,
  }) async {
    final local = await _localIpv4();
    if (local == null) return const <DiscoveredCamera>[];

    final parts = local.split('.');
    if (parts.length != 4) return const <DiscoveredCamera>[];
    final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';

    final results = <DiscoveredCamera>[];
    final queue = List<int>.generate(254, (index) => index + 1);
    var cursor = 0;

    Future<void> worker() async {
      while (true) {
        final index = cursor++;
        if (index >= queue.length) return;
        final host = '$prefix.${queue[index]}';
        if (host == local) continue;

        final open = <int>[];
        for (final port in defaultPorts) {
          if (await _isOpen(host, port, timeout)) open.add(port);
        }
        if (open.isEmpty) continue;

        final streams = open.contains(554) ? buildRtspCandidates(host) : const <String>[];
        results.add(DiscoveredCamera(host: host, openPorts: open, streamCandidates: streams));
      }
    }

    final workers = List<Future<void>>.generate(concurrency, (_) => worker());
    await Future.wait(workers);
    results.sort((a, b) => a.host.compareTo(b.host));
    return results;
  }

  Future<String?> _localIpv4() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLoopback: false);
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final ip = address.address;
        if (_isPrivateIpv4(ip)) return ip;
      }
    }
    return null;
  }

  bool _isPrivateIpv4(String ip) {
    final p = ip.split('.').map(int.tryParse).toList();
    if (p.length != 4 || p.any((e) => e == null)) return false;
    final a = p[0]!;
    final b = p[1]!;
    return a == 10 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
  }

  Future<bool> _isOpen(String host, int port, Duration timeout) async {
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
}
