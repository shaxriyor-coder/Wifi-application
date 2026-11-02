/// TZ v4 §2 — holat mashinasi.
///
/// Holat faqat uch sabab bilan o'zgaradi: (1) foydalanuvchi tugma bosdi,
/// (2) HTTP so'rov yoki native metod javob qaytardi, (3) ilova fondan
/// qaytdi — bu holda faqat [checking] ga qaytiladi.
enum AppState {
  checking, // kirish tekshiruvi ketmoqda
  noNetwork, // hech qanday tarmoq yo'q
  mobileData, // mobil internet, Wi-Fi emas
  hotspot, // boshqa telefonning hotspotiga ulangan
  unreachable, // Wi-Fi bor, lekin router javob bermayapti
  unsupported, // qurilma qo'llab-quvvatlanmaydi
  needLogin, // foydalanuvchidan login so'ralmoqda
  loginHelp, // kirish ma'lumotlari haqida yordam matni
  loggingIn, // foydalanuvchi kiritgan parol yuborilmoqda
  loginFailed, // parol noto'g'ri
  menu, // amal tanlanmoqda
  devicesLoading, // ulangan qurilmalar ro'yxati yuklanmoqda
  devices, // ulangan qurilmalar ro'yxati ko'rsatilmoqda
  devicesFailed, // ro'yxatni olib bo'lmadi
  ssidEdit, // yangi nom kiritilmoqda
  keyEdit, // yangi parol kiritilmoqda
  applying, // o'zgartirish yuborilmoqda
  success,
  failure,
}
