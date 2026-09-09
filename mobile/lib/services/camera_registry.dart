import 'package:shared_preferences/shared_preferences.dart';
import '../models/camera.dart';

class CameraRegistry {
  static const _storageKey = 'apk_all_camera.devices.v1';

  Future<List<CameraDevice>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return CameraDevice.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<CameraDevice> devices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, CameraDevice.encodeList(devices));
  }
}
