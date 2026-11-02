import 'package:flutter/material.dart';

/// TZ v3 §8 — "Tekshiruv" ekrani. Holat: checking.
/// Tarkibi: xabar + indikator (§12 matni).
class CheckingScreen extends StatelessWidget {
  const CheckingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text('Tekshirilmoqda...'),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
