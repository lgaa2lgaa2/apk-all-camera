import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum RtspValidationStatus {
  valid,
  authenticationRequired,
  unavailable,
}

class RtspValidationResult {
  const RtspValidationResult({
    required this.status,
    required this.url,
  });

  final RtspValidationStatus status;
  final String url;
}

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

  static RtspValidationStatus parseDescribeResponse(String response) {
    final headerEnd = response.indexOf('\r\n\r\n');
    final headerBlock = headerEnd >= 0 ? response.substring(0, headerEnd) : response;
    final lines = const LineSplitter().convert(headerBlock);
    if (lines.isEmpty) return RtspValidationStatus.unavailable;

    final match = RegExp(r'^RTSP/\d+(?:\.\d+)?\s+(\d{3})\b').firstMatch(lines.first.trim());
    final statusCode = int.tryParse(match?.group(1) ?? '');

    if (statusCode == 401) {
      return RtspValidationStatus.authenticationRequired;
    }
    if (statusCode != 200) {
      return RtspValidationStatus.unavailable;
    }

    final hasSdpContentType = lines.any(
      (line) => line.toLowerCase().startsWith('content-type:') &&
          line.toLowerCase().contains('application/sdp'),
    );
    final body = headerEnd >= 0 ? response.substring(headerEnd + 4) : '';
    final looksLikeSdp = body.contains('v=0') || body.contains('m=video');

    return hasSdpContentType && looksLikeSdp
        ? RtspValidationStatus.valid
        : RtspValidationStatus.unavailable;
  }

  Future<RtspValidationResult> validateRtspResource(
    String url, {
    Duration timeout = const Duration(milliseconds: 900),
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme.toLowerCase() != 'rtsp' || uri.host.isEmpty) {
      return RtspValidationResult(
        status: RtspValidationStatus.unavailable,
        url: url,
      );
    }

    final port = uri.hasPort ? uri.port : 554;
    Socket? socket;
    StreamSubscription<List<int>>? subscription;
    final response = StringBuffer();
    final completer = Completer<RtspValidationStatus>();

    void completeFromResponse() {
      if (!completer.isCompleted) {
        completer.complete(parseDescribeResponse(response.toString()));
      }
    }

    try {
      socket = await Socket.connect(uri.host, port, timeout: timeout);
      subscription = socket.listen(
        (data) {
          response.write(utf8.decode(data, allowMalformed: true));
          if (response.toString().contains('\r\n\r\n')) {
            completeFromResponse();
          }
        },
        onError: (_) {
          if (!completer.isCompleted) {
            completer.complete(RtspValidationStatus.unavailable);
          }
        },
        onDone: completeFromResponse,
        cancelOnError: true,
      );

      final normalizedPath = uri.path.isEmpty ? '/' : uri.path;
      final query = uri.hasQuery ? '?${uri.query}' : '';
      final authority = uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
      final request = 'DESCRIBE rtsp://$authority$normalizedPath$query RTSP/1.0\r\n'
          'CSeq: 1\r\n'
          'Accept: application/sdp\r\n'
          'User-Agent: APK-All-Camera\r\n'
          '\r\n';

      socket.write(request);
      await socket.flush();
      final status = await completer.future.timeout(
        timeout,
        onTimeout: () => RtspValidationStatus.unavailable,
      );
      return RtspValidationResult(status: status, url: url);
    } catch (_) {
      return RtspValidationResult(
        status: RtspValidationStatus.unavailable,
        url: url,
      );
    } finally {
      await subscription?.cancel();
      socket?.destroy();
    }
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
      final result = await validateRtspResource(candidate);
      if (result.status == RtspValidationStatus.valid) return candidate;
    }
    return null;
  }
}
