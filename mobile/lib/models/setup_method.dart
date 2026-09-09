enum CameraSetupMethod {
  qr,
  acoustic,
  bluetooth,
  accessPoint,
  networkDiscovery,
  manual,
}

extension CameraSetupMethodLabel on CameraSetupMethod {
  String get label {
    switch (this) {
      case CameraSetupMethod.qr:
        return 'QR code devant la caméra';
      case CameraSetupMethod.acoustic:
        return 'Son / bip-bip';
      case CameraSetupMethod.bluetooth:
        return 'Bluetooth';
      case CameraSetupMethod.accessPoint:
        return 'Point d’accès Wi-Fi';
      case CameraSetupMethod.networkDiscovery:
        return 'Détection réseau ONVIF/RTSP';
      case CameraSetupMethod.manual:
        return 'Ajout manuel';
    }
  }

  String get description {
    switch (this) {
      case CameraSetupMethod.qr:
        return 'Affiche un QR code au téléphone pour que la caméra le lise.';
      case CameraSetupMethod.acoustic:
        return 'Émet un signal sonore de configuration si le protocole du fabricant est connu.';
      case CameraSetupMethod.bluetooth:
        return 'Associe la caméra via Bluetooth lorsqu’elle le permet.';
      case CameraSetupMethod.accessPoint:
        return 'Connexion au Wi-Fi temporaire créé par la caméra.';
      case CameraSetupMethod.networkDiscovery:
        return 'Recherche automatiquement les caméras ONVIF/RTSP présentes sur le réseau.';
      case CameraSetupMethod.manual:
        return 'Saisit directement l’adresse RTSP/HTTP et les identifiants.';
    }
  }
}
