import 'dart:convert';

enum CameraConnectionType { rtsp, http, mjpeg, proprietary }

class CameraDevice {
  const CameraDevice({
    required this.id,
    required this.name,
    required this.family,
    required this.streamUrl,
    required this.connectionType,
    this.username = '',
    this.password = '',
    this.location = '',
    this.enabled = true,
  });

  final String id;
  final String name;
  final String family;
  final String streamUrl;
  final CameraConnectionType connectionType;
  final String username;
  final String password;
  final String location;
  final bool enabled;

  Uri? authenticatedUri() {
    final uri = Uri.tryParse(streamUrl.trim());
    if (uri == null || username.isEmpty) return uri;
    return uri.replace(userInfo: '${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'family': family,
        'streamUrl': streamUrl,
        'connectionType': connectionType.name,
        'username': username,
        'password': password,
        'location': location,
        'enabled': enabled,
      };

  factory CameraDevice.fromJson(Map<String, dynamic> json) => CameraDevice(
        id: json['id'] as String,
        name: json['name'] as String,
        family: json['family'] as String? ?? 'Autre',
        streamUrl: json['streamUrl'] as String? ?? '',
        connectionType: CameraConnectionType.values.firstWhere(
          (value) => value.name == json['connectionType'],
          orElse: () => CameraConnectionType.rtsp,
        ),
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
        location: json['location'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
      );

  static String encodeList(List<CameraDevice> devices) =>
      jsonEncode(devices.map((camera) => camera.toJson()).toList());

  static List<CameraDevice> decodeList(String source) {
    final values = jsonDecode(source) as List<dynamic>;
    return values
        .map((entry) => CameraDevice.fromJson(entry as Map<String, dynamic>))
        .toList();
  }
}
