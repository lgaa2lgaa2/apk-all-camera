import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StreamValidator {
  const StreamValidator();

  static bool isRtspEndpointResponse(String response) {
    final lines = const LineSplitter().convert(response);
    if (lines.isEmpty) return false;
    final firstLine = lines.first.trim();
    if (!firstLine.startsWith('RTSP/')) return false;

    final match = RegExp(r'^RTSP/\d+(?:\.\d+)?\s+(\d{3})\b').firstMatch(firstLine);
    if (match == null) return false;
    final statusCode = int.tryParse(match.group(1) ?? '');
    return statusCode == 200 || statusCode == 401;
  }

  Future<bool> canReachRtsp(
    Uri uri, {
    Duration timeout = const Duration(milliseconds: 900),
  }) async {
    if (uri.scheme.toLowerCase() != 'rtsp' || uri.host.isEmpty) return false;
    final port = uri.hasPort ? uri.port : 554;
    Socket? socket;
    StreamSubscription<List<int>>? subscription;
    final response = StringBuffer();
    final completer = Completer<bool>();

    void complete(bool value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    try {
      socket = await Socket.connect(uri.host, port, timeout: timeout);
      subscription = socket.listen(
        (data) {
          response.write(utf8.decode(data, allowMalformed: true));
          if (response.toString().contains('\r\n\r\n')) {
            complete(isRtspEndpointResponse(response.toString()));
          }
        },
        onError: (_) => complete(false),
        onDone: () => complete(isRtspEndpointResponse(response.toString())),
        cancelOnError: true,
      );

      final normalizedPath = uri.path.isEmpty ? '/' : uri.path;
      final query = uri.hasQuery ? '?${uri.query}' : '';
      final authority = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
      final request = 'OPTIONS rtsp://$authority$normalizedPath$query RTSP/1.0\r\n'
          'CSeq: 1\r\n'
          'User-Agent: APK-All-Camera\r\n'
          '\r\n';

      socket.write(request);
      await socket.flush();
      return await completer.future.timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    } finally {
      await subscription?.cancel();
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
