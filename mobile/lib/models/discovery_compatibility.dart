enum DiscoveryCompatibilityStatus {
  compatible,
  authenticationRequired,
  partial,
  proprietaryUnsupported,
  unavailable,
}

class DiscoveryCompatibilityResult {
  const DiscoveryCompatibilityResult({
    required this.host,
    required this.detectedServices,
    required this.status,
    required this.explanation,
    this.validatedStream,
    this.candidateEndpoint,
  });

  final String host;
  final List<String> detectedServices;
  final String? validatedStream;
  final String? candidateEndpoint;
  final DiscoveryCompatibilityStatus status;
  final String explanation;

  bool get canPrefillStream =>
      status == DiscoveryCompatibilityStatus.compatible &&
      validatedStream != null &&
      validatedStream!.trim().isNotEmpty;
}
