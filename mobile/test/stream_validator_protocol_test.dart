import 'package:apk_all_camera/services/stream_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RTSP response parser accepts success and auth-required endpoints', () {
    expect(StreamValidator.isRtspEndpointResponse('RTSP/1.0 200 OK\r\nCSeq: 1\r\n\r\n'), isTrue);
    expect(StreamValidator.isRtspEndpointResponse('RTSP/1.0 401 Unauthorized\r\nCSeq: 1\r\n\r\n'), isTrue);
    expect(StreamValidator.isRtspEndpointResponse('HTTP/1.1 200 OK\r\n\r\n'), isFalse);
  });
}
