import 'package:http/http.dart' as http;

import 'detector.dart';
import 'network_info.dart';

/// Kirish tekshiruvi tugagach ilova qaysi holatga o'tishi kerakligi.
/// TZ v3 §6.1 jadvalidagi "To'xtasa" ustuni.
enum EntryState {
  noNetwork,
  mobileData,
  unreachable,
  hotspot,
  unsupported,
  loginRequired,
}

/// [EntryCheck.run] natijasi: qaysi holatga o'tish kerakligi va, aniqlangan
/// bo'lsa, gateway IP. Qo'llab-quvvatlanadigan router topilganda gateway
/// adapter yaratish va foydalanuvchidan login so'rash uchun kerak.
class EntryCheckResult {
  const EntryCheckResult(this.state, {this.gateway});

  final EntryState state;
  final String? gateway;
}

/// TZ v3 §6 — kirish tekshiruvining olti qadami.
///
/// Har bir qadam o'tsa keyingisiga o'tiladi. Birortasi to'xtatsa,
/// mos [EntryState] qaytariladi va qolgan qadamlar bajarilmaydi.
///
/// §6.3: internet mavjudligi tekshirilmaydi.
class EntryCheck {
  EntryCheck({NetworkInfo? networkInfo, http.Client? client})
      : _networkInfo = networkInfo ?? const NetworkInfo(),
        _client = client ?? http.Client();

  final NetworkInfo _networkInfo;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 4);

  /// §6.2 — tanish hotspot gateway diapazonlari. Ro'yxat to'liq emas
  /// (§6.2): noma'lum hotspot 4- yoki 5-qadamda baribir to'xtaydi.
  static const List<String> _hotspotPrefixes = <String>[
    '192.168.43.', // Android hotspot
    '172.20.10.', // iPhone hotspot
    '192.168.137.', // Windows hotspot
  ];

  void close() => _client.close();

  Future<EntryCheckResult> run() async {
    // 1-qadam: ulanish turi.
    final NetworkType type = await _networkInfo.getNetworkType();
    switch (type) {
      case NetworkType.none:
        return const EntryCheckResult(EntryState.noNetwork);
      case NetworkType.mobile:
        return const EntryCheckResult(EntryState.mobileData);
      case NetworkType.wifi:
        break;
    }

    // 2-qadam: gateway IP qaytdimi.
    final String? gateway = await _networkInfo.getGatewayIp();
    if (gateway == null) {
      return const EntryCheckResult(EntryState.unreachable);
    }

    // 3-qadam: gateway hotspot diapazonida emasmi.
    if (_isHotspot(gateway)) {
      return EntryCheckResult(EntryState.hotspot, gateway: gateway);
    }

    // 4-qadam: gateway GET so'roviga javob berdimi.
    final http.Response response;
    try {
      response =
          await _client.get(Uri.parse('http://$gateway/')).timeout(_timeout);
    } on Exception {
      return EntryCheckResult(EntryState.unreachable, gateway: gateway);
    }

    // 5-qadam: javob HTML'ida HG8245H5 modeli bormi.
    if (!Detector.isHg8245h5(response.body)) {
      return EntryCheckResult(EntryState.unsupported, gateway: gateway);
    }

    // Router tasdiqlandi. Kirish ma'lumotlarini avtomatik sinamaymiz;
    // foydalanuvchi ularni o'zi kiritishi kerak.
    return EntryCheckResult(EntryState.loginRequired, gateway: gateway);
  }

  static bool _isHotspot(String gateway) {
    for (final String prefix in _hotspotPrefixes) {
      if (gateway.startsWith(prefix)) return true;
    }
    return false;
  }
}
