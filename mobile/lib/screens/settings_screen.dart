import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool mobileVideo = true;
  bool biometrics = false;
  bool push = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: mobileVideo,
            onChanged: (v) => setState(() => mobileVideo = v),
            title: const Text('Vidéo sur 4G/5G'),
            subtitle: const Text('Autoriser la lecture vidéo quand le téléphone n’est pas en Wi-Fi.'),
          ),
          SwitchListTile(
            value: push,
            onChanged: (v) => setState(() => push = v),
            title: const Text('Notifications push'),
            subtitle: const Text('Alertes mouvement, personne, véhicule, animal, hors ligne et stockage.'),
          ),
          SwitchListTile(
            value: biometrics,
            onChanged: (v) => setState(() => biometrics = v),
            title: const Text('Déverrouillage biométrique'),
            subtitle: const Text('Option locale, sans remplacer le mot de passe du compte.'),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.high_quality),
              title: Text('Qualité vidéo'),
              subtitle: Text('Auto • Économie • HD • Full HD • 2K • 4K selon la caméra.'),
            ),
          ),
        ],
      ),
    );
  }
}
