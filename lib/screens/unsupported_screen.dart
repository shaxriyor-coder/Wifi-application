import 'package:flutter/material.dart';

/// TZ v3 §8 — "Mos emas" ekrani. Holat: unsupported.
/// Tarkibi: faqat xabar, boshqa hech narsa (§12 matni).
class UnsupportedScreen extends StatelessWidget {
  const UnsupportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              "Sizning qurilmangiz hozircha qo'llab-quvvatlanmaydi. Tez orada qo'shamiz.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
