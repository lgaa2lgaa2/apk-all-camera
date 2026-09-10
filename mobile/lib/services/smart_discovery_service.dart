import '../models/discovery_compatibility.dart';
import 'network_discovery_service.dart';
import 'onvif_discovery.dart';
import 'stream_validator.dart';

class SmartDiscoveryService {
  SmartDiscoveryService({
    NetworkDiscoveryService? networkDiscovery,
    OnvifDiscovery? onvifDiscovery,
    StreamValidator? streamValidator,
  })  : _networkDiscovery = networkDiscovery ?? NetworkDiscoveryService(),
        _onvifDiscovery = onvifDiscovery ?? const OnvifDiscovery(),
        _streamValidator = streamValidator ?? const StreamValidator();

  final NetworkDiscoveryService _networkDiscovery;
  final OnvifDiscovery _onvifDiscovery;
  final StreamValidator _streamValidator;

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
    final services = _servicesFromPorts(camera.openPorts);

    return classifyHost(
      host: camera.host,
      detectedServices: services.toList(growable: false),
      authenticationRequired: false,
      validatedStream: camera.validatedStream,
      candidateEndpoint:
          camera.streamCandidates.isEmpty ? null : camera.streamCandidates.first,
    );
  }

  Future<List<DiscoveryCompatibilityResult>> discover() async {
    List<DiscoveredCamera> networkResults;
    List<OnvifProbeResult> onvifResults;

    try {
      networkResults = await _networkDiscovery.scanLocalSubnet();
    } catch (_) {
      networkResults = const <DiscoveredCamera>[];
    }

    try {
      onvifResults = await _onvifDiscovery.discover();
    } catch (_) {
      onvifResults = const <OnvifProbeResult>[];
    }

    final networkByHost = <String, DiscoveredCamera>{
      for (final camera in networkResults) camera.host: camera,
    };
    final onvifByHost = <String, List<OnvifProbeResult>>{};
    for (final result in onvifResults) {
      onvifByHost.putIfAbsent(result.host, () => <OnvifProbeResult>[]).add(result);
    }

    final hosts = <String>{...networkByHost.keys, ...onvifByHost.keys}.toList()
      ..sort();
    final results = <DiscoveryCompatibilityResult>[];

    for (final host in hosts) {
      final networkCamera = networkByHost[host];
      final onvifEvidence = onvifByHost[host] ?? const <OnvifProbeResult>[];
      final services = <String>{};
      final candidates = <String>[];
      String? validatedStream = networkCamera?.validatedStream;
      String? candidateEndpoint;
      var authenticationRequired = false;

      if (networkCamera != null) {
        services.addAll(_servicesFromPorts(networkCamera.openPorts));
        candidates.addAll(networkCamera.streamCandidates);
      }

      if (onvifEvidence.isNotEmpty) {
        services.add('ONVIF');
        for (final candidate in OnvifDiscovery.fallbackRtspCandidates(host)) {
          if (!candidates.contains(candidate)) candidates.add(candidate);
        }
      }

      if (validatedStream == null || validatedStream.trim().isEmpty) {
        for (final candidate in candidates) {
          final validation = await _streamValidator.validateRtspResource(candidate);
          if (validation.status == RtspValidationStatus.valid) {
            validatedStream = validation.url;
            candidateEndpoint = validation.url;
            break;
          }
          if (validation.status == RtspValidationStatus.authenticationRequired) {
            authenticationRequired = true;
            candidateEndpoint = validation.url;
            break;
          }
        }
      } else {
        candidateEndpoint = validatedStream;
      }

      candidateEndpoint ??= onvifEvidence.isEmpty ? null : onvifEvidence.first.xaddr;

      results.add(
        classifyHost(
          host: host,
          detectedServices: services.toList(growable: false),
          authenticationRequired: authenticationRequired,
          validatedStream: validatedStream,
          candidateEndpoint: candidateEndpoint,
        ),
      );
    }

    return results;
  }

  static Set<String> _servicesFromPorts(List<int> ports) {
    final services = <String>{};
    if (ports.any((port) => port == 80 || port == 8000 || port == 8080 || port == 8899)) {
      services.add('HTTP');
    }
    if (ports.contains(554)) {
      services.add('RTSP');
    }
    return services;
  }
}
