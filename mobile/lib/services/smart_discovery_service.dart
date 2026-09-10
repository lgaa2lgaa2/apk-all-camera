import '../models/discovery_compatibility.dart';
import 'network_discovery_service.dart';

class SmartDiscoveryService {
  const SmartDiscoveryService();

  static DiscoveryCompatibilityResult classifyHost({
    required String host,
    required List<String> detectedServices,
    required bool authenticationRequired,
    String? validatedStream,
    String? candidateEndpoint,
  }) {
    final hasValidatedStream =
        validatedStream != null && validatedStream.trim().isNotEmpty;

    if (hasValidatedStream) {
      return DiscoveryCompatibilityResult(
        host: host,
        detectedServices: detectedServices,
        status: DiscoveryCompatibilityStatus.compatible,
        explanation: 'Flux RTSP validé.',
        validatedStream: validatedStream,
        candidateEndpoint: candidateEndpoint,
      );
    }

    if (authenticationRequired) {
      return DiscoveryCompatibilityResult(
        host: host,
        detectedServices: detectedServices,
        status: DiscoveryCompatibilityStatus.authenticationRequired,
        explanation: 'Authentification requise pour accéder au flux caméra.',
        candidateEndpoint: candidateEndpoint,
      );
    }

    if (detectedServices.isNotEmpty) {
      return DiscoveryCompatibilityResult(
        host: host,
        detectedServices: detectedServices,
        status: DiscoveryCompatibilityStatus.partial,
        explanation: 'Services caméra détectés, mais aucun flux validé.',
        candidateEndpoint: candidateEndpoint,
      );
    }

    return DiscoveryCompatibilityResult(
      host: host,
      detectedServices: detectedServices,
      status: DiscoveryCompatibilityStatus.unavailable,
      explanation: 'Aucun service caméra compatible détecté.',
      candidateEndpoint: candidateEndpoint,
    );
  }

  static DiscoveryCompatibilityResult fromDiscoveredCamera(
    DiscoveredCamera camera,
  ) {
    final services = <String>{};
    if (camera.openPorts.any((port) => port == 80 || port == 8000 || port == 8080 || port == 8899)) {
      services.add('HTTP');
    }
    if (camera.hasRtspServer) {
      services.add('RTSP');
    }

    return classifyHost(
      host: camera.host,
      detectedServices: services.toList(growable: false),
      authenticationRequired: false,
      validatedStream: camera.validatedStream,
      candidateEndpoint: camera.streamCandidates.isEmpty ? null : camera.streamCandidates.first,
    );
  }
}
