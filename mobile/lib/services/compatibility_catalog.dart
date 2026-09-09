class CameraFamily {
  const CameraFamily(this.name, this.notes, {this.openProtocolPreferred = false});
  final String name;
  final String notes;
  final bool openProtocolPreferred;
}

const cameraFamilies = <CameraFamily>[
  CameraFamily('ONVIF / RTSP', 'Caméras IP standard. Compatibilité prioritaire.', openProtocolPreferred: true),
  CameraFamily('V380 / V380 Pro', 'Tester RTSP/ONVIF si le firmware les expose ; sinon connecteur propriétaire requis.'),
  CameraFamily('iCSee / iCSee Pro', 'Nombreux modèles OEM ; privilégier RTSP/ONVIF quand disponible.'),
  CameraFamily('Yoosee', 'Écosystème P2P fréquent ; certains modèles offrent RTSP/ONVIF.'),
  CameraFamily('CamHi / CamHiPro', 'Souvent compatible RTSP/ONVIF suivant le modèle.'),
  CameraFamily('UBox', 'Nombreuses caméras 4G/solaires ; cloud propriétaire fréquent.'),
  CameraFamily('360Eyes / 360Eyes Pro', 'Connecteur propriétaire selon modèle.'),
  CameraFamily('Cam720 / Cam720 Pro', 'Connecteur propriétaire selon modèle.'),
  CameraFamily('Neye3C', 'Tester ONVIF/RTSP suivant modèle.'),
  CameraFamily('StarEye / STAREyes', 'Connecteur propriétaire selon modèle.'),
  CameraFamily('DV380', 'Famille proche des écosystèmes P2P chinois ; vérifier protocole par modèle.'),
  CameraFamily('VicoHome', 'Cloud propriétaire sur beaucoup de modèles.'),
  CameraFamily('Cloud365', 'Cloud/P2P ; connecteur fabricant nécessaire si aucun flux ouvert.'),
  CameraFamily('iCam / ICAM', 'Nom utilisé par plusieurs OEM ; identifier le protocole réel.'),
  CameraFamily('Tuya / Smart Life', 'Intégration dépend du produit et de l’API/SDK du fabricant.'),
  CameraFamily('YCC365 Plus', 'Cloud/P2P fréquent ; RTSP/ONVIF variable.'),
  CameraFamily('IPC360 / IPC360 Home', 'Cloud/P2P propriétaire fréquent.'),
  CameraFamily('O-KAM Pro', 'Connecteur propriétaire selon modèle.'),
  CameraFamily('CareCam / CareCam Pro', 'Connecteur propriétaire selon modèle.'),
  CameraFamily('XMEye / XMEye Pro', 'Écosystème DVR/NVR et caméras IP ; RTSP/ONVIF fréquent.'),
  CameraFamily('EseeCloud', 'Écosystème NVR/P2P ; compatibilité variable.'),
  CameraFamily('Danale', 'Cloud/P2P propriétaire fréquent.'),
  CameraFamily('Autre / Générique', 'Ajouter directement une URL RTSP/HTTP/MJPEG si disponible.'),
];
