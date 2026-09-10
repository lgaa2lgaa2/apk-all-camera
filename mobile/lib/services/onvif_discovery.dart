import 'dart:async';
import 'dart:convert';
import 'dart:io';

class OnvifProbeResult {
  const OnvifProbeResult({required this.xaddr, required this.host});
  final String xaddr;
  final String host;
}

class OnvifDiscovery {
  const OnvifDiscovery();

  static const String _probeXml = '''<?xml version="1.0" encoding="UTF-8"?>
<e:Envelope xmlns:e="http://www.w3.org/2003/05/soap-envelope" xmlns:w="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:dn="http://www.onvif.org/ver10/network/wsdl">
  <e:Header>
    <w:MessageID>uuid:apk-all-camera</w:MessageID>
    <w:To e:mustUnderstand="true">urn:schemas-xmlsoap-org:ws:2005:04:discovery</w:To>
    <w:Action e:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</w:Action>
  </e:Header>
  <e:Body>
    <d:Probe><d:Types>dn:NetworkVideoTransmitter</d:Types></d:Probe>
  </e:Body>
</e:Envelope>''';

  static List<String> parseProbeMatches(String xml) {
    final values = <String>{};
    final re = RegExp(r'<(?:\w+:)?XAddrs>([^<]+)</(?:\w+:)?XAddrs>', caseSensitive: false);
    for (final match in re.allMatches(xml)) {
      final raw = match.group(1) ?? '';
      for (final value in raw.split(RegExp(r'\s+'))) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) values.add(trimmed);
      }
    }
    return values.toList(growable: false);
  }

  static List<String> fallbackRtspCandidates(String host) => <String>[
        'rtsp://$host:554/stream1',
        'rtsp://$host:554/Streaming/Channels/101',
        'rtsp://$host:554/cam/realmonitor?channel=1&subtype=0',
        'rtsp://$host:554/h264Preview_01_main',
        'rtsp://$host:554/live/ch00_0',
      ];

  Future<List<OnvifProbeResult>> discover({Duration timeout = const Duration(seconds: 3)}) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final results = <OnvifProbeResult>[];
    final seen = <String>{};
    final done = Completer<void>();
    Timer? timer;

    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      final body = utf8.decode(datagram.data, allowMalformed: true);
      for (final xaddr in parseProbeMatches(body)) {
        final uri = Uri.tryParse(xaddr);
        final host = uri?.host ?? '';
        if (host.isEmpty || !seen.add(xaddr)) continue;
        results.add(OnvifProbeResult(xaddr: xaddr, host: host));
      }
    });

    final target = InternetAddress('239.255.255.250');
    final payload = utf8.encode(_probeXml);
    socket.send(payload, target, 3702);
    socket.send(payload, target, 3702);
    timer = Timer(timeout, () {
      if (!done.isCompleted) done.complete();
    });

    await done.future;
    timer.cancel();
    socket.close();
    return results;
  }
}
