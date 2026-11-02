import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v3 §8 — "Hotspot" ekrani. Holat: hotspot.
/// Tarkibi: xabar + "Qayta urinish" (§12 matni).
class HotspotScreen extends StatelessWidget {
  const HotspotScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Siz boshqa telefonning internetiga ulangansiz. Uy tarmog'ingizga ulaning.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.retry(),
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }
}
