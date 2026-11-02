import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v4 §3.1 — Menyu ekrani. Holat: menu.
/// Tarkibi: "Tarmoq nomini o'zgartirish" va "Tarmoq parolini o'zgartirish"
/// tugmalari (§3.1 matni).
///
/// Joriy parol bu yerda KO'RSATILMAYDI: yonida turgan odam ekrandan
/// o'qib olishi mumkin. Faqat joriy nom ko'rsatiladi.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Nima qilmoqchisiz?', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Hozirgi nom: ${controller.currentSsid}',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.goToSsidEdit(),
              child: const Text("Tarmoq nomini o'zgartirish"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.goToKeyEdit(),
              child: const Text("Tarmoq parolini o'zgartirish"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.goToDevices(),
              child: const Text('Ulangan qurilmalar'),
            ),
          ],
        ),
      ),
    );
  }
}
