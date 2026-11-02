import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models/app_state.dart';

/// TZ v4 §2 va §6 — "Natija" ekrani. Holatlar: success, failure.
/// Tarkibi: xabar + "Ortga" (§12 matni).
///
/// Matn [AppController.lastAction] ga qarab tanlanadi — nom o'zgardimi
/// yoki parol. `lastAction` `null` bo'lmasligi kerak (success/failure ga
/// faqat `apply`/`applyKey` orqali kelinadi), lekin himoya uchun `null`
/// holatda nom variantidan foydalaniladi.
///
/// §12 — success dan keyin ilova hech narsa qilmaydi: sozlamalarni
/// ochmaydi, o'zi qayta ulanmaydi, taymer qo'ymaydi. Faqat xabar va tugma.
///
/// "Ortga":
///  - success da telefon Wi-Fi'dan uzilgan bo'ladi, router bilan aloqa
///    yo'q — menu ma'nosiz, tekshiruv boshidan ishlashi kerak
///    ([AppController.retry]).
///  - failure da router bilan aloqa bor — to'g'ridan menu ga qaytadi
///    ([AppController.backToMenu]).
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final bool ok = controller.state == AppState.success;
    final bool isKey = controller.lastAction == LastAction.key;

    final String message;
    if (ok) {
      message = isKey
          ? "Tarmoq paroli o'zgartirildi. Endi barcha qurilmalaringizni "
                "yangi parol bilan qayta ulang."
          : "Tarmoq nomi o'zgartirildi. Endi barcha qurilmalaringizni "
                "yangi nom bilan qayta ulang.";
    } else {
      message = isKey
          ? "Parolni o'zgartirib bo'lmadi. Qayta urinib ko'ring."
          : "Nomni o'zgartirib bo'lmadi. Qayta urinib ko'ring.";
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (ok) {
                  controller.retry();
                } else {
                  controller.backToMenu();
                }
              },
              child: const Text('Ortga'),
            ),
          ],
        ),
      ),
    );
  }
}
