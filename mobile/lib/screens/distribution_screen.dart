import 'package:flutter/material.dart';

class DistributionScreen extends StatelessWidget {
  const DistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribution')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.android, color: Color(0xFF4FD6FF)),
              title: Text('Android', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('APK release généré par GitHub Actions et distribuable depuis le VPS ou GitHub.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.phone_iphone, color: Color(0xFF4FD6FF)),
              title: Text('iPhone', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Distribution prévue via TestFlight avec un compte Apple Developer.'),
            ),
          ),
        ],
      ),
    );
  }
}
