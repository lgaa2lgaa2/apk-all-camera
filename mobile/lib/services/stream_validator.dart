import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StreamValidator {
  const StreamValidator();

  static bool isRtspEndpointResponse(String response) {
    final firstLine = const LineSplitter().convert(response).firstOrNull ?? '';
    if (!firstLine.startsWith('RTSP/')) return false;
    return firstLine.contains(' 200 ') || firstLine.contains(' 401 ');
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

      final target = uri.path.isEmpty ? '/' : uri.path;
      final request = StringBuffer()
        ..writeln('OPTIONS rtsp://${uri.host}:$port$target RTSP/1.0\r')
        ..writeln('CSeq: 1\r')
        ..writeln('User-Agent: APK-All-Camera\r')
        ..writeln('\r');
      socket.write(request.toString());
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

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
