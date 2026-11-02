import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v6 — "Kirish yordami" ekrani. Holat: loginHelp.
///
/// Foydalanuvchilar Wi-Fi parolini qurilma paneli paroli bilan
/// chalkashtiradi. Bu ekran farqni tushuntiradi va provayderga aynan
/// qanday so'z bilan murojaat qilishni aytadi.
///
/// Matn uzun, kichik ekranlarga sig'masligi mumkin — [SingleChildScrollView].
class LoginHelpScreen extends StatelessWidget {
  const LoginHelpScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Text('Bu Wi-Fi paroli emas.', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'Wi-Fi paroli — telefoningizni tarmoqqa ulaganda kiritadigan '
                'parol. Bu yerda esa qurilmaning sozlamalariga kirish uchun '
                'boshqa ma\'lumot kerak.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Qurilma orqasidagi stikerda yozilgan ma\'lumot bu yerga '
                'to\'g\'ri kelmaydi — u boshqa maqsad uchun.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ilova routerga avtomatik kirishga urinmaydi. Xavfsizlik '
                'uchun faqat o\'zingiz kiritgan ma\'lumotlardan foydalanadi.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Router sozlamalari uchun admin login va parolini '
                'provayderingizdan yoki routerni sozlagan mutaxassisdan oling.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.backFromLoginHelp(),
                child: const Text('Ortga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
