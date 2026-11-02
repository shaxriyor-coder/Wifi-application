/// TZ v3 §6.1 — 5-qadam: model aniqlash.
///
/// [EntryCheck] 4-qadamda gateway'dan olgan HTML matnini qabul qiladi.
/// Yangi HTTP so'rov yubormaydi — HTML tashqaridan beriladi.
class Detector {
  const Detector._();

  /// Router panelining HTML'ida HG8245H5 modeli ko'rinsa `true`.
  static bool isHg8245h5(String html) {
    return html.contains('HG8245H5');
  }
}
