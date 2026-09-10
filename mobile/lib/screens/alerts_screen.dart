import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool person = true, vehicle = true, animal = true, offline = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Column(children: [
            SwitchListTile(value: person, onChanged: (v)=>setState(()=>person=v), title: const Text('Personne')),
            SwitchListTile(value: vehicle, onChanged: (v)=>setState(()=>vehicle=v), title: const Text('Véhicule')),
            SwitchListTile(value: animal, onChanged: (v)=>setState(()=>animal=v), title: const Text('Animal')),
            SwitchListTile(value: offline, onChanged: (v)=>setState(()=>offline=v), title: const Text('Hors ligne')),
          ])),
          const SizedBox(height: 12),
          const Card(child: ListTile(leading: Icon(Icons.person_search), title: Text('Personne détectée'), subtitle: Text('Entrée · événement récent'))),
          const Card(child: ListTile(leading: Icon(Icons.directions_car), title: Text('Véhicule détecté'), subtitle: Text('Parking · événement récent'))),
        ],
      ),
    );
  }
}
