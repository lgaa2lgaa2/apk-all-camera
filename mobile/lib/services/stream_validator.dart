import 'dart:async';
import 'dart:io';

class StreamValidator {
  const StreamValidator();

  Future<bool> canReachRtsp(Uri uri, {Duration timeout = const Duration(milliseconds: 700)}) async {
    if (uri.scheme.toLowerCase() != 'rtsp' || uri.host.isEmpty) return false;
    final port = uri.hasPort ? uri.port : 554;
    Socket? socket;
    try {
      socket = await Socket.connect(uri.host, port, timeout: timeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  Future<String?> firstReachable(List<String> candidates) async {
    for (final candidate in candidates) {
      final uri = Uri.tryParse(candidate);
      if (uri == null) continue;
      if (await canReachRtsp(uri)) return candidate;
    }
    return null;
  }
}
