import 'package:flutter/material.dart';

/// TZ v3 §8 — "Qo'llanmoqda" ekrani. Holat: applying.
/// Tarkibi: xabar + indikator. Tugma yo'q (§12 matni).
class ApplyingScreen extends StatelessWidget {
  const ApplyingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text("O'zgartirilmoqda..."),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
