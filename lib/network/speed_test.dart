import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/result.dart';

/// TZ v7 §1 — bitta o'lchov natijasi. Hech qayerda saqlanmaydi,
/// faqat xotirada, ekranga ko'rsatish uchun.
class SpeedResult {
  const SpeedResult({
    required this.pingMs,
    required this.downloadMbps,
    required this.uploadMbps,
  });

  final int pingMs;
  final double downloadMbps;
  final double uploadMbps;
}

/// TZ v7 §1 — Cloudflare speed nuqtasidan uch o'lchov: javob vaqti,
/// yuklab olish, yuklash. Routerdan mustaqil.
///
/// Bitta nuqta, bitta urinish. Server tanlash, o'rtacha hisoblash yoki
/// natijani "yaxshilash" yo'q. Server javob bermasa — [Result.fail].
///
/// Bekor qilish: [close] oqimni uzadi, davom etayotgan o'lchov xato bilan
/// tugaydi.
class SpeedTest {
  SpeedTest({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _pingUri =
      Uri.parse('https://speed.cloudflare.com/__down?bytes=0');
  static final Uri _downloadUri =
      Uri.parse('https://speed.cloudflare.com/__down?bytes=25000000');
  static final Uri _uploadUri = Uri.parse('https://speed.cloudflare.com/__up');

  /// Yuklash uchun yuboriladigan tana hajmi. Tezlik formulasidagi
  /// 1000000 bilan bir xil o'nlik o'lchov: 10 MB = 10 * 1000 * 1000.
  static const int _uploadBytes = 10 * 1000 * 1000;

  static const Duration _transferTimeout = Duration(seconds: 60);
  static const Duration _pingTimeout = Duration(seconds: 10);

  /// Tezlik Mbit/s da: (baytlar * 8) / soniya / 1000000.
  static double _mbps(int bytes, Stopwatch sw) {
    final double seconds = sw.elapsedMicroseconds / 1000000;
    return bytes * 8 / seconds / 1000000;
  }

  /// Javob vaqti — 0 baytli GET ning to'liq borib-kelish vaqti (ms).
  Future<Result<int>> ping() async {
    try {
      final Stopwatch sw = Stopwatch()..start();
      final http.Response res =
          await _client.get(_pingUri).timeout(_pingTimeout);
      sw.stop();
      if (res.statusCode != 200) {
        return Result<int>.fail('Javob vaqtini o\'lchab bo\'lmadi');
      }
      return Result<int>.ok(sw.elapsedMilliseconds);
    } catch (_) {
      return Result<int>.fail('Javob vaqtini o\'lchab bo\'lmadi');
    }
  }

  /// Yuklab olish — javob oqimini bo'lak-bo'lak o'qib, baytlarni sanaydi.
  Future<Result<double>> download() async {
    try {
      final Stopwatch sw = Stopwatch()..start();
      final int bytes = await _receive().timeout(_transferTimeout);
      sw.stop();
      if (bytes <= 0 || sw.elapsedMicroseconds <= 0) {
        return Result<double>.fail('Yuklab olish tezligini o\'lchab bo\'lmadi');
      }
      return Result<double>.ok(_mbps(bytes, sw));
    } catch (_) {
      return Result<double>.fail('Yuklab olish tezligini o\'lchab bo\'lmadi');
    }
  }

  Future<int> _receive() async {
    final http.StreamedResponse res =
        await _client.send(http.Request('GET', _downloadUri));
    if (res.statusCode != 200) {
      throw http.ClientException('HTTP ${res.statusCode}', _downloadUri);
    }
    int bytes = 0;
    await for (final List<int> chunk in res.stream) {
      bytes += chunk.length;
    }
    return bytes;
  }

  /// Yuklash — 10 MB tanani POST qiladi, yuborish vaqtini o'lchaydi.
  Future<Result<double>> upload() async {
    try {
      final Uint8List body = Uint8List(_uploadBytes);
      final http.Request req = http.Request('POST', _uploadUri)
        ..headers['Content-Type'] = 'application/octet-stream'
        ..bodyBytes = body;

      final Stopwatch sw = Stopwatch()..start();
      final int status = await _send(req).timeout(_transferTimeout);
      sw.stop();
      if (status != 200 || sw.elapsedMicroseconds <= 0) {
        return Result<double>.fail('Yuklash tezligini o\'lchab bo\'lmadi');
      }
      return Result<double>.ok(_mbps(_uploadBytes, sw));
    } catch (_) {
      return Result<double>.fail('Yuklash tezligini o\'lchab bo\'lmadi');
    }
  }

  Future<int> _send(http.Request req) async {
    final http.StreamedResponse res = await _client.send(req);
    await res.stream.drain<void>();
    return res.statusCode;
  }

  /// Bekor qilish va tozalash. Davom etayotgan o'lchov xato bilan tugaydi.
  void close() => _client.close();
}
