import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v3 §8 — "Mobil internet" ekrani. Holat: mobileData.
/// Tarkibi: xabar + "Wi-Fi sozlamalari" + "Qayta urinish" (§12 matni).
class MobileDataScreen extends StatelessWidget {
  const MobileDataScreen({super.key, required this.controller});

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
              "Siz mobil internetdasiz. Wi-Fi'ni yoqing va uy tarmog'ingizga ulaning.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.openWifiSettings(),
              child: const Text('Wi-Fi sozlamalari'),
            ),
            const SizedBox(height: 12),
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
