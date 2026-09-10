import '../models/discovery_compatibility.dart';

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
}
