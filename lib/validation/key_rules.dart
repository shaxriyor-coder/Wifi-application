/// TZ v4 §4 — Parol qoidalari.
///
/// Yangi parolni tekshiradi. Xato bo'lsa o'zbekcha xabar qaytaradi, to'g'ri
/// bo'lsa `null`. Tugma faqat `null` qaytganda faollashadi.
///
/// [confirmKey] — takrorlangan parol, ikkala maydon bir xilligini
/// tekshirish uchun.
/// [currentKey] — joriy parol, eskisi bilan bir xil emasligini
/// tekshirish uchun.

/// Ruxsat etilgan belgilar: lotin harflari, raqamlar va
/// ! @ # $ % ^ * ( ) - _ + = . ,
/// Kirill harflari va emoji ataylab taqiqlangan (§4): ba'zi qurilmalar
/// bunday parolni qabul qilmaydi.
final RegExp _allowed = RegExp(r'^[A-Za-z0-9!@#$%^*()\-_+=.,]+$');

String? validateKey(String newKey, String confirmKey, String currentKey) {
  if (newKey.length < 8) {
    return 'Parol kamida 8 ta belgidan iborat bo\'lishi kerak.';
  }
  if (newKey.length > 63) {
    return 'Parol 63 ta belgidan oshmasligi kerak.';
  }
  if (newKey != newKey.trim()) {
    return 'Parol boshida yoki oxirida bo\'sh joy bo\'lmasin.';
  }
  if (!_allowed.hasMatch(newKey)) {
    return 'Faqat lotin harflari, raqamlar va oddiy belgilardan foydalaning.';
  }
  if (newKey != confirmKey) {
    return 'Parollar bir xil emas.';
  }
  if (newKey == currentKey) {
    return 'Yangi parol eskisi bilan bir xil.';
  }
  return null;
}
