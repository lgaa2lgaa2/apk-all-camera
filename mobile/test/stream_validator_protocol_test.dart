import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apk_all_camera/services/stream_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RTSP response parser accepts success and auth-required endpoints', () {
    expect(StreamValidator.isRtspEndpointResponse('RTSP/1.0 200 OK\r\nCSeq: 1\r\n\r\n'), isTrue);
    expect(StreamValidator.isRtspEndpointResponse('RTSP/1.0 401 Unauthorized\r\nCSeq: 1\r\n\r\n'), isTrue);
    expect(StreamValidator.isRtspEndpointResponse('HTTP/1.1 200 OK\r\n\r\n'), isFalse);
  });

  test('DESCRIBE parser validates an SDP resource', () {
    const response = 'RTSP/1.0 200 OK\r\n'
        'CSeq: 1\r\n'
        'Content-Type: application/sdp\r\n'
        'Content-Length: 20\r\n'
        '\r\n'
        'v=0\r\nm=video 0 RTP/AVP 96\r\n';

    expect(
      StreamValidator.parseDescribeResponse(response),
      RtspValidationStatus.valid,
    );
  });

  test('DESCRIBE parser reports authentication required on 401', () {
    const response = 'RTSP/1.0 401 Unauthorized\r\nCSeq: 1\r\n\r\n';

    expect(
      StreamValidator.parseDescribeResponse(response),
      RtspValidationStatus.authenticationRequired,
    );
  });

  test('DESCRIBE parser reports unavailable on missing resource', () {
    const response = 'RTSP/1.0 404 Not Found\r\nCSeq: 1\r\n\r\n';

    expect(
      StreamValidator.parseDescribeResponse(response),
      RtspValidationStatus.unavailable,
    );
  });

  test('DESCRIBE waits for SDP body announced by Content-Length', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    final serverDone = Completer<void>();
    server.listen((socket) async {
      try {
        await socket.cast<List<int>>().transform(utf8.decoder).first;
        const body = 'v=0\r\nm=video 0 RTP/AVP 96\r\n';
        socket.write(
          'RTSP/1.0 200 OK\r\n'
          'CSeq: 1\r\n'
          'Content-Type: application/sdp\r\n'
          'Content-Length: ${body.length}\r\n'
          '\r\n',
        );
        await socket.flush();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        socket.write(body);
        await socket.flush();
      } finally {
        await socket.close();
        if (!serverDone.isCompleted) serverDone.complete();
      }
    });

    final result = await const StreamValidator().validateRtspResource(
      'rtsp://127.0.0.1:${server.port}/stream1',
      timeout: const Duration(seconds: 1),
    );

    expect(result.status, RtspValidationStatus.valid);
    await serverDone.future;
  });
}
