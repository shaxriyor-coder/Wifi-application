import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v3 §8 — "Router topilmadi" ekrani. Holat: unreachable.
/// Tarkibi: xabar + "Qayta urinish" (§12 matni).
class UnreachableScreen extends StatelessWidget {
  const UnreachableScreen({super.key, required this.controller});

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
              "Uy qurilmangiz topilmadi. Wi-Fi'ga to'g'ri ulanganingizni tekshiring.",
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
