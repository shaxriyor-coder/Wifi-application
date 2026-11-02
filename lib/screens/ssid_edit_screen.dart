import 'package:flutter/material.dart';

import '../app_controller.dart';

/// TZ v3 §8 — "Yangi nom" ekrani. Holat: ready.
/// Tarkibi: 1 ta maydon + "O'zgartirish" (§12 matni).
///
/// §11 — har bir belgi kiritilganda [AppController.validate] chaqiriladi;
/// natija `null` bo'lmasa maydon tagida ko'rsatiladi va tugma o'chiq turadi.
/// Maydon bo'sh bo'lsa xato ko'rsatilmaydi (foydalanuvchi hali yozmagan),
/// tugma baribir o'chiq turadi.
class SsidEditScreen extends StatefulWidget {
  const SsidEditScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SsidEditScreen> createState() => _SsidEditScreenState();
}

class _SsidEditScreenState extends State<SsidEditScreen> {
  // §8 — maydon bo'sh boshlanadi, joriy nom bilan to'ldirilmaydi.
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String text = _name.text;

    // Bo'sh maydonda tekshiruv ishlamaydi — xato ko'rsatilmaydi.
    final String? error =
        text.isEmpty ? null : widget.controller.validate(text);

    // Tugma: faqat maydon to'ldirilgan va tekshiruv toza bo'lganda faol.
    final bool canApply = text.isNotEmpty && error == null;

    final List<Widget> children = <Widget>[
      const Text('Yangi nom kiriting.', textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text('Hozirgi nom: ${widget.controller.currentSsid}',
          textAlign: TextAlign.center),
      const SizedBox(height: 24),
      TextField(controller: _name),
    ];

    if (error != null) {
      children.add(const SizedBox(height: 12));
      children.add(Text(error, textAlign: TextAlign.center));
    }

    children.add(const SizedBox(height: 24));
    children.add(ElevatedButton(
      onPressed: canApply ? () => widget.controller.apply(_name.text) : null,
      child: const Text("O'zgartirish"),
    ));
    children.add(const SizedBox(height: 12));
    children.add(ElevatedButton(
      onPressed: () => widget.controller.backToMenu(),
      child: const Text('Ortga'),
    ));

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
