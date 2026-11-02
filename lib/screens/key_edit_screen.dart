import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v4 §3.2 — "Yangi parol" ekrani. Holat: keyEdit.
/// Tarkibi: 2 ta maydon (yangi parol, takrorlash) + "Ko'rsatish" belgisi +
/// "O'zgartirish" (§3.2 matni).
///
/// §4 — har bir belgi kiritilganda [AppController.validateKeyInput]
/// chaqiriladi; natija `null` bo'lmasa maydonlar tagida ko'rsatiladi va
/// tugma o'chiq turadi. Ikkala maydon bo'sh bo'lsa xato ko'rsatilmaydi
/// (foydalanuvchi hali yozmagan). Takrorlash maydoni hali bo'sh bo'lsa
/// "Parollar bir xil emas" xatosi ko'rsatilmaydi — foydalanuvchi hali
/// terib bo'lmagan; bu holatda ham tugma o'chiq turadi.
class KeyEditScreen extends StatefulWidget {
  const KeyEditScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<KeyEditScreen> createState() => _KeyEditScreenState();
}

class _KeyEditScreenState extends State<KeyEditScreen> {
  // §3.2 — ikkala maydon ham bo'sh boshlanadi, joriy parol yozilmaydi.
  final TextEditingController _newKey = TextEditingController();
  final TextEditingController _confirmKey = TextEditingController();

  // "Ko'rsatish" belgisi — bosilganda ikkala maydon ham ochiq matnga
  // aylanadi.
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _newKey.addListener(_onChanged);
    _confirmKey.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _newKey.dispose();
    _confirmKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String newVal = _newKey.text;
    final String confirmVal = _confirmKey.text;

    // Takrorlash maydoni bo'sh bo'lsa, haqiqiy tekshiruv o'tkazilmaydi —
    // faqat tugma holatini bilish uchun quyida alohida hisoblanadi.
    final String? realError = confirmVal.isEmpty
        ? null
        : widget.controller.validateKeyInput(newVal, confirmVal);

    // Ekranda ko'rsatiladigan xato: ikkala maydon bo'sh bo'lsa — yo'q;
    // faqat takrorlash bo'sh bo'lsa — "mos kelmadi" xatosi bostiriladi,
    // lekin yangi parolning o'z xatolari (uzunlik, belgi, bo'sh joy,
    // eskisi bilan bir xillik) baribir ko'rsatiladi.
    String? error;
    if (newVal.isEmpty && confirmVal.isEmpty) {
      error = null;
    } else if (confirmVal.isEmpty) {
      error = widget.controller.validateKeyInput(newVal, newVal);
    } else {
      error = realError;
    }

    // Tugma: ikkala maydon ham to'ldirilgan va haqiqiy tekshiruv toza
    // bo'lganda faol.
    final bool canApply =
        newVal.isNotEmpty && confirmVal.isNotEmpty && realError == null;

    final List<Widget> children = <Widget>[
      const Text('Yangi parol kiriting.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      const Text('Yangi parol', textAlign: TextAlign.center),
      const SizedBox(height: 8),
      TextField(controller: _newKey, obscureText: !_showPassword),
      const SizedBox(height: 24),
      const Text('Parolni takrorlang', textAlign: TextAlign.center),
      const SizedBox(height: 8),
      TextField(controller: _confirmKey, obscureText: !_showPassword),
      const SizedBox(height: 12),
      Checkbox(
        value: _showPassword,
        onChanged: (bool? value) =>
            setState(() => _showPassword = value ?? false),
      ),
      const Text("Ko'rsatish"),
    ];

    if (error != null) {
      children.add(const SizedBox(height: 12));
      children.add(Text(error, textAlign: TextAlign.center));
    }

    children.add(const SizedBox(height: 24));
    children.add(
      ElevatedButton(
        onPressed: canApply
            ? () => widget.controller.applyKey(_newKey.text, _confirmKey.text)
            : null,
        child: const Text("O'zgartirish"),
      ),
    );
    children.add(const SizedBox(height: 12));
    children.add(
      ElevatedButton(
        onPressed: () => widget.controller.backToMenu(),
        child: const Text('Ortga'),
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
