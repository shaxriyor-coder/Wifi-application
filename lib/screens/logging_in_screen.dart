import 'package:flutter/material.dart';

/// TZ v3 §8 — "Yuborilmoqda" ekrani. Holat: loggingIn.
/// Tarkibi: xabar + indikator. Tugma yo'q.
class LoggingInScreen extends StatelessWidget {
  const LoggingInScreen({super.key});

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
