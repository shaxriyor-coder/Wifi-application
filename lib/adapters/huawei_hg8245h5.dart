import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/result.dart';
/// Routerdan o'qib olingan joriy WLAN sozlamalari.
/// Hamma qiymat WlanBasic.asp sahifasining HTML'idan olinadi.
class WlanConfig {
  final String ssid;
  final String enable; // 1 / 0
  final String broadcast; // 1 / 0
  final String associateNum; // 1..32
  final String beaconType; // WPAand11i
  final String mixAuth; // PSKAuthentication
  final String mixEnc; // TKIPandAESEncryption
  final String groupRekey; // 3600
  final String standard; // 11bgn
  final String preSharedKey; // Wi-Fi paroli
  final String wpsEnable; // 1 / 0
  final String wpsConfigMethod; // PushButton
  final String token; // x.X_HW_Token
  const WlanConfig({
    required this.ssid,
    required this.enable,
    required this.broadcast,
    required this.associateNum,
    required this.beaconType,
    required this.mixAuth,
    required this.mixEnc,
    required this.groupRekey,
    required this.standard,
    required this.preSharedKey,
    required this.wpsEnable,
    required this.wpsConfigMethod,
    required this.token,
  });

  @override
  String toString() =>
      'WlanConfig(ssid: $ssid, standard: $standard, auth: $mixAuth, '
      'enc: $mixEnc, rekey: $groupRekey, wps: $wpsEnable, parol: ${preSharedKey.isEmpty ? "(bo'sh)" : "(${preSharedKey.length} belgi)"})';
}

/// LAN'ga ulangan bitta qurilma.
///
/// Barcha qiymat GetLanUserDevInfo.asp javobidagi `new USERDevice(...)`
/// chaqiruvidan olinadi. [name] router bermasa bo'sh bo'lishi mumkin.
class LanDevice {
  final String name;
  final String mac;
  final String ip;
  final bool online;
  const LanDevice({
    required this.name,
    required this.mac,
    required this.ip,
    required this.online,
  });

  @override
  String toString() =>
      'LanDevice(${name.isEmpty ? "(nomsiz)" : name}, $mac, $ip, '
      '${online ? "online" : "offline"})';
}

/// Huawei EchoLife HG8245H5 uchun adapter.
///
/// Barcha so'rovlar real qurilmadan DevTools orqali olingan.
/// Hech qanday soxta javob yo'q: router javob bermasa, xato qaytariladi.
class HuaweiHg8245h5 {
  HuaweiHg8245h5({this.host = '192.168.100.1', http.Client? client})
      : _client = client ?? http.Client();

  final String host;
  final http.Client _client;

  static const _timeout = Duration(seconds: 10);

  /// Login qilishdan oldingi cookie. Routerdan kuzatilgan qiymat.
  String _cookie = 'Cookie=body:Language:english:id=-1';

  static const _wlanPage = '/html/amp/wlanbasic/WlanBasic.asp';
  static const _randCount = '/asp/GetRandCount.asp';

  static const _setCgi = '/html/amp/wlanbasic/set.cgi'
      '?w=InternetGatewayDevice.X_HW_DEBUG.AMP.WifiCoverSetWlanBasic'
      '&y=InternetGatewayDevice.LANDevice.1.WLANConfiguration.1'
      '&z=InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPS'
      '&k=InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1'
      '&RequestFile=html/amp/wlanbasic/WlanBasic.asp';

  String get modelId => 'huawei-hg8245h5';

  void close() => _client.close();


  /// Routerga kiradi. Muvaffaqiyatli bo'lsa sessiya cookie'si saqlanadi.
  Future<Result<void>> login(String username, String password) async {
    // Token alohida so'rovdan olinadi. Kirish sahifasida onttoken yo'q.
    final rand = await _post(_randCount, const {});
    if (!rand.ok) return Result.fail(rand.error);

    // Javob BOM bilan keladi, shuning uchun hex qismini ajratib olamiz.
    final token = RegExp(r'[0-9a-fA-F]{32}').firstMatch(rand.data!)?.group(0);
    if (token == null) {
      return const Result.fail('Token olinmadi.');
    }

    final res = await _post('/login.cgi', {
      'UserName': username,
      'PassWord': base64Encode(utf8.encode(password)),
      'x.X_HW_Token': token,
    });
    if (!res.ok) return Result.fail(res.error);

    if (!_cookie.contains('sid=') || !_cookie.contains('id=1')) {
      return const Result.fail('Foydalanuvchi nomi yoki parol noto\'g\'ri.');
    }
    return const Result.ok();
  }

  // ------------------------------------------------------------ o'qish

  /// Joriy WLAN sozlamalarini o'qiydi.
  ///
  /// Bu majburiy qadam: set.cgi butun formani qabul qiladi, shuning uchun
  /// mavjud parol va shifrlash sozlamalari qayta yuborilishi kerak.
  Future<Result<WlanConfig>> readWlanConfig() async {
    final page = await _get(_wlanPage);
    if (!page.ok) return Result.fail(page.error);
    final html = page.data!;

    final token = _extractToken(html);
    if (token == null) {
      return const Result.fail('Sozlamalar sahifasidan token topilmadi.');
    }

    final wlan = _ctorArgs(html, 'stWlan');
    final wifi = _ctorArgs(html, 'stWlanWifi');
    final psk = _ctorArgs(html, 'stPreSharedKey');
    final wps = _ctorArgs(html, 'stWpsPin');

    if (wlan == null || wlan.length < 19) {
      return const Result.fail('Sozlamalarni o\'qib bo\'lmadi (stWlan).');
    }
    if (psk == null || psk.length < 2) {
      return const Result.fail('Parolni o\'qib bo\'lmadi (stPreSharedKey).');
    }

    final cfg = WlanConfig(
      enable: wlan[2],
      ssid: wlan[3],
      broadcast: wlan[4],
      associateNum: wlan[5],
      beaconType: wlan[7],
      mixEnc: wlan[16],
      mixAuth: wlan[17],
      groupRekey: wlan[18],
      standard: (wifi != null && wifi.length > 4) ? wifi[4] : '11bgn',
      preSharedKey: psk[1],
      wpsEnable: (wps != null && wps.length > 4) ? wps[4] : '0',
      wpsConfigMethod: (wps != null && wps.length > 1) ? wps[1] : 'PushButton',
      token: token,
    );

    // v1 faqat WPA/WPA2-PSK sozlamasini qo'llab-quvvatlaydi.
    // Boshqa rejimda w.* maydonlari boshqacha bo'ladi va noto'g'ri
    // yuborilsa parol buzilishi mumkin — shuning uchun to'xtaymiz.
    if (cfg.beaconType != 'WPAand11i' || cfg.mixAuth != 'PSKAuthentication') {
      return const Result.fail(
        'Bu router boshqa xavfsizlik rejimida sozlangan, v1 uni qo\'llab-quvvatlamaydi.',
      );
    }
    if (cfg.preSharedKey.isEmpty) {
      return const Result.fail(
        'Joriy parol o\'qilmadi. Xavfsizlik uchun to\'xtatildi.',
      );
    }

    return Result.ok(cfg);
  }

  // ------------------------------------------------------- o'zgartirish

  /// Wi-Fi nomini o'zgartiradi.
  ///
  /// So'rov yuborilgach Wi-Fi uziladi va javob kelmasligi mumkin.
  /// TZ 8-bo'limiga ko'ra, AYNAN SHU YERDA aloqa uzilishi muvaffaqiyat
  /// deb hisoblanadi. Boshqa hech qayerda bu qoida qo'llanilmaydi.
  Future<Result<void>> changeSsid(String newSsid) => _applyWlan(ssid: newSsid);

  /// Wi-Fi parolini o'zgartiradi.
  ///
  /// changeSsid bilan bir xil forma va yo'l orqali yuboriladi. Aloqa
  /// uzilishi bu yerda ham muvaffaqiyat deb hisoblanadi — parol
  /// o'zgarganda ham Wi-Fi uziladi.
  Future<Result<void>> changePassword(String newKey) =>
      _applyWlan(key: newKey);

  /// changeSsid va changePassword uchun umumiy forma qurish va yuborish.
  ///
  /// [ssid] berilsa — SSID o'zgaradi va eskisi bilan bir xillik shu yerda
  /// tekshiriladi. [key] berilsa — parol o'zgaradi. Berilmagan maydon
  /// joriy qiymatida qoladi. readWlanConfig faqat bir marta chaqiriladi.
  Future<Result<void>> _applyWlan({String? ssid, String? key}) async {
    final read = await readWlanConfig();
    if (!read.ok) return Result.fail(read.error);
    final c = read.data!;

    if (ssid != null && ssid == c.ssid) {
      return const Result.fail('Yangi nom eskisi bilan bir xil.');
    }

    final ssidValue = ssid ?? c.ssid;
    final keyValue = key ?? c.preSharedKey;

    final body = <String, String>{
      // y.* — asosiy WLAN sozlamalari
      'y.Enable': c.enable,
      'y.SSIDAdvertisementEnabled': c.broadcast,
      'y.SSID': ssidValue,
      'y.X_HW_AssociateNum': c.associateNum,
      'y.BeaconType': c.beaconType,
      'y.X_HW_WPAand11iAuthenticationMode': c.mixAuth,
      'y.X_HW_WPAand11iEncryptionModes': c.mixEnc,
      'k.PreSharedKey': keyValue,
      'y.X_HW_GroupRekey': c.groupRekey,

      // z.* — WPS, joriy holatida qoldiriladi
      'z.Enable': c.wpsEnable,
      'z.X_HW_ConfigMethod': c.wpsConfigMethod,

      // w.* — WifiCover bloki. Panel WPA/WPA2-PSK rejimida aynan shu
      // qiymatlarni yuboradi (DevTools'dan olingan).
      'w.SsidInst': '1',
      'w.SSID': ssidValue,
      'w.Enable': c.enable,
      'w.Standard': c.standard,
      'w.BasicAuthenticationMode': 'None',
      'w.BasicEncryptionModes': 'TKIPandAESEncryption',
      'w.WPAAuthenticationMode': 'EAPAuthentication',
      'w.WPAEncryptionModes': 'TKIPandAESEncryption',
      'w.IEEE11iAuthenticationMode': 'EAPAuthentication',
      'w.IEEE11iEncryptionModes': 'TKIPandAESEncryption',
      'w.MixAuthenticationMode': c.mixAuth,
      'w.MixEncryptionModes': c.mixEnc,
      'w.BeaconType': c.beaconType,
      'w.WEPEncryptionLevel': '104-bit',
      'w.WEPKeyIndex': '1',
      'w.Key': keyValue,

      'x.X_HW_Token': c.token,
    };

    try {
      final res = await _client
          .post(
            Uri.parse('http://$host$_setCgi'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Cookie': _cookie,
              'Referer': 'http://$host$_wlanPage',
              'Origin': 'http://$host',
            },
            body: _encodeForm(body),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) return const Result.ok();
      return Result.fail('Router javobi: ${res.statusCode}');
    } on SocketException {
      // Wi-Fi uzildi — nom yoki parol o'zgargani uchun. Muvaffaqiyat.
      return const Result.ok();
    } on http.ClientException {
      return const Result.ok();
    } on Exception catch (e) {
      // Timeout ham shu yerga tushadi.
      if (e.toString().contains('TimeoutException')) return const Result.ok();
      return Result.fail('Xato: $e');
    }
  }

  // ------------------------------------------------------- qurilmalar

  static const _lanDevPage =
      '/html/bbsp/common/GetLanUserDevInfo.asp';
  static const _lanDevReferer =
      '/html/bbsp/userdevinfo/userdevinfo.asp';

  /// LAN'ga ulangan barcha qurilmalarni qaytaradi.
  ///
  /// Javob — JavaScript matni, ichida har bir qurilma uchun bitta
  /// `new USERDevice(...)` chaqiruvi. Javob to'liq ro'yxatni beradi,
  /// sahifalash brauzerda bo'ladi — bitta so'rov yetarli.
  ///
  /// Router javob bermasa yoki HTTP xato bo'lsa — Result.fail.
  /// Qurilma topilmasa bu xato emas — bo'sh ro'yxat bilan Result.ok.
  Future<Result<List<LanDevice>>> listDevices() async {
    final res = await _post(
      _lanDevPage,
      const {},
      referer: 'http://$host$_lanDevReferer',
      xhr: true,
    );
    if (!res.ok) return Result.fail(res.error);

    final devices = <LanDevice>[];
    for (final args in _allCtorArgs(res.data!, 'USERDevice')) {
      if (args.length < 10) continue;
      devices.add(LanDevice(
        ip: args[1],
        mac: args[2],
        online: args[6] == 'Online',
        name: args[9],
      ));
    }
    return Result.ok(devices);
  }

  // ------------------------------------------------------------ ichki

  Future<Result<String>> _get(String path) async {
    try {
      final res = await _client.get(
        Uri.parse('http://$host$path'),
        headers: {'Cookie': _cookie},
      ).timeout(_timeout);
      _saveCookie(res);
      if (res.statusCode != 200) {
        return Result.fail('Router javobi: ${res.statusCode}');
      }
      return Result.ok(res.body);
    } on SocketException {
      return const Result.fail('Routerga ulanib bo\'lmadi.');
    } on Exception catch (e) {
      return Result.fail('Xato: $e');
    }
  }

  /// [referer] berilmasa bosh sahifa ishlatiladi (mavjud chaqiruvlar
  /// shunga tayanadi). [xhr] true bo'lsa X-Requested-With qo'shiladi.
  Future<Result<String>> _post(
    String path,
    Map<String, String> form, {
    String? referer,
    bool xhr = false,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': _cookie,
        'Referer': referer ?? 'http://$host/',
        'Origin': 'http://$host',
      };
      if (xhr) headers['X-Requested-With'] = 'XMLHttpRequest';
      final res = await _client
          .post(
            Uri.parse('http://$host$path'),
            headers: headers,
            body: _encodeForm(form),
          )
          .timeout(_timeout);
      _saveCookie(res);
      if (res.statusCode != 200) {
        return Result.fail('Router javobi: ${res.statusCode}');
      }
      return Result.ok(res.body);
    } on SocketException {
      return const Result.fail('Routerga ulanib bo\'lmadi.');
    } on Exception catch (e) {
      return Result.fail('Xato: $e');
    }
  }

  void _saveCookie(http.Response res) {
    final raw = res.headers['set-cookie'];
    if (raw == null || raw.isEmpty) return;
    _cookie = raw.split(';').first.trim();
  }

  static String _encodeForm(Map<String, String> form) => form.entries
      .map((e) =>
          '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  /// <INPUT type="hidden" name="onttoken" id="hwonttoken" value="..." />
  static String? _extractToken(String html) {
    final tag = RegExp(
      r'<input[^>]*name\s*=\s*"onttoken"[^>]*>',
      caseSensitive: false,
    ).firstMatch(html);
    if (tag == null) return null;
    final value = RegExp(
      r'value\s*=\s*"([^"]*)"',
      caseSensitive: false,
    ).firstMatch(tag.group(0)!);
    return value?.group(1);
  }

  /// `new stWlan("a","b",...)` chaqiruvidan argumentlarni ajratib oladi.
  static List<String>? _ctorArgs(String html, String ctor) {
    final call = RegExp('new\\s+$ctor\\s*\\(([^)]*)\\)').firstMatch(html);
    if (call == null) return null;
    return RegExp(r'"((?:[^"\\]|\\.)*)"')
        .allMatches(call.group(1)!)
        .map((m) => _unescape(m.group(1)!))
        .toList();
  }

  /// `_ctorArgs` kabi, lekin BARCHA mos kelgan `new $ctor(...)`
  /// chaqiruvlarini qaytaradi. Har bir element — bitta chaqiruvning
  /// _unescape qilingan argumentlari. Mos kelmasa — bo'sh ro'yxat.
  static List<List<String>> _allCtorArgs(String js, String ctor) {
    return RegExp('new\\s+$ctor\\s*\\(([^)]*)\\)')
        .allMatches(js)
        .map((call) => RegExp(r'"((?:[^"\\]|\\.)*)"')
            .allMatches(call.group(1)!)
            .map((m) => _unescape(m.group(1)!))
            .toList())
        .toList();
  }

  /// \x2e -> .  \x2b -> +  \x2d -> -
  static String _unescape(String s) => s.replaceAllMapped(
        RegExp(r'\\x([0-9a-fA-F]{2})'),
        (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
      );
}