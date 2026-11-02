/// TZ v3 §11 — SSID qoidalari.
///
/// Nomni tekshiradi. Xato bo'lsa o'zbekcha xabar qaytaradi, to'g'ri
/// bo'lsa `null`. Tugma faqat `null` qaytganda faollashadi.
///
/// [currentSsid] — joriy tarmoq nomi, bir xillikni tekshirish uchun.

/// Ruxsat etilgan belgilar: lotin harflari, raqamlar, `-` va `_`.
/// Kirill harflari va emoji ataylab taqiqlangan (§11): ba'zi eski
/// qurilmalar bunday nomdagi tarmoqni ko'rmaydi.
final RegExp _allowed = RegExp(r'^[A-Za-z0-9_-]+$');

String? validateSsid(String value, String currentSsid) {
  if (value.isEmpty) {
    return 'Nom kamida 1 ta belgidan iborat bo\'lishi kerak.';
  }
  if (value.length > 32) {
    return 'Nom 32 ta belgidan oshmasligi kerak.';
  }
  if (value != value.trim()) {
    return 'Nom boshida yoki oxirida bo\'sh joy bo\'lmasin.';
  }
  if (!_allowed.hasMatch(value)) {
    return 'Faqat lotin harflari, raqamlar, - va _ belgilaridan foydalaning.';
  }
  if (value == currentSsid) {
    return 'Yangi nom joriy nom bilan bir xil.';
  }
  return null;
}
