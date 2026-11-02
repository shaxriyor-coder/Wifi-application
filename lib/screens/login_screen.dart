import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models/app_state.dart';

/// TZ v3 §8 — "Kirish" ekrani. Holatlar: needLogin, loginFailed.
/// Tarkibi: 2 ta maydon + "Davom etish" (§12 matni).
///
/// §10.2 — maydonlar bo'sh boshlanadi, oldindan to'ldirilmaydi.
/// §10.3 — login/parol faqat [TextEditingController] da turadi, ekran
/// yopilganda [dispose] da yo'qoladi; boshqa hech qayerda saqlanmaydi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user.addListener(_onChanged);
    _pass.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // §8: "Davom etish" faqat ikkala maydon ham to'ldirilganda yoqiladi
    // (bo'sh parol bilan so'rov yuborilmasin).
    final bool bothFilled = _user.text.isNotEmpty && _pass.text.isNotEmpty;

    // loginFailed da xato matni ko'rsatiladi; maydonlar tozalanmaydi.
    final String message = widget.controller.state == AppState.loginFailed
        ? "Kirish ma'lumotlari noto'g'ri. Qayta kiriting."
        : "Router administratorining login va parolini kiriting.";

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              "Xavfsizlik: routerga kirish ma'lumotlari shifrlanmagan "
              "HTTP orqali yuboriladi. Faqat ishonchli Wi-Fi tarmog'ida "
              "davom eting.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            const Text('Login'),
            TextField(controller: _user),
            const SizedBox(height: 12),
            const Text('Parol'),
            TextField(controller: _pass, obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: bothFilled
                  ? () => widget.controller
                      .submitLogin(_user.text, _pass.text)
                  : null,
              child: const Text('Davom etish'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => widget.controller.goToLoginHelp(),
              child: const Text("Ma'lumotlarni bilmayapsizmi?"),
            ),
          ],
        ),
      ),
    );
  }
}
