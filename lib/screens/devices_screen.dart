import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models/app_state.dart';

/// TZ v5 §4 — "Ulangan qurilmalar" ekrani.
/// Holatlar: devicesLoading, devices, devicesFailed — uchalasini ham
/// shu bitta ekran ko'rsatadi ([AppController.state] ga qarab).
///
/// §4 — ekranda faqat qurilma nomi ko'rsatiladi. MAC, IP va boshqa
/// texnik ma'lumot chiqarilmaydi. Ro'yxatda faqat hozir ulangan
/// qurilmalar bo'ladi (filtrni [AppController.deviceList] qiladi).
///
/// Ro'yxat o'zi yangilanmaydi: "Yangilash" tugmasi [AppController.goToDevices]
/// ni qayta chaqiradi, taymer yo'q. Qatorlar bosilmaydi.
///
/// "Ortga" — [AppController.backToMenu] orqali menyuga qaytaradi.
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (controller.state) {
      case AppState.devicesLoading:
        body = _loading();
        break;
      case AppState.devicesFailed:
        body = _failed();
        break;
      default:
        body = _list();
        break;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: body,
      ),
    );
  }

  Widget _loading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Text('Yuklanmoqda...', textAlign: TextAlign.center),
        SizedBox(height: 24),
        CircularProgressIndicator(),
      ],
    );
  }

  Widget _failed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Ro'yxatni olib bo'lmadi. Qayta urinib ko'ring.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => controller.goToDevices(),
          child: const Text('Qayta urinish'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => controller.backToMenu(),
          child: const Text('Ortga'),
        ),
      ],
    );
  }

  Widget _list() {
    // Tur nomi atay yozilmagan: ekran faqat AppController bilan gaplashadi,
    // qatorga esa faqat `name` kerak.
    final devices = controller.deviceList;

    final Widget middle;
    if (devices.isEmpty) {
      middle = const Center(
        child: Text(
          'Hozir hech qanday qurilma ulanmagan.',
          textAlign: TextAlign.center,
        ),
      );
    } else {
      middle = ListView(
        children: <Widget>[
          for (final device in devices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                device.name.isEmpty ? "Noma'lum qurilma" : device.name,
              ),
            ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        const Text('Hozir ulangan qurilmalar', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Expanded(child: middle),
        const SizedBox(height: 24),
        const Text(
          "Notanish qurilma ko'rsangiz, tarmoq parolini o'zgartiring. "
          'Shunda ular tushib qoladi.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => controller.goToKeyEdit(),
          child: const Text("Parolni o'zgartirish"),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => controller.goToDevices(),
          child: const Text('Yangilash'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => controller.backToMenu(),
          child: const Text('Ortga'),
        ),
      ],
    );
  }
}
