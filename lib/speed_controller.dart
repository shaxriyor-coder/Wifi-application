import 'package:flutter/foundation.dart';

import 'models/result.dart';
import 'network/speed_test.dart';

/// Ekran qaysi bosqich ketayotganini shundan biladi ("Yuklab olish
/// o'lchanmoqda..." kabi matnlar uchun).
enum SpeedState { idle, ping, download, upload, done, failed }

/// TZ v7 §2 — internet tezligi o'lchovini boshqaradi.
///
/// [AppController] dan butunlay alohida: bir-birini import qilmaydi,
/// holatlari aralashmaydi.
///
/// O'lchov faqat [start] chaqirilganda boshlanadi — avtomatik emas,
/// davriy emas, taymer yo'q. Natija hech qayerda saqlanmaydi.
class SpeedController extends ChangeNotifier {
  SpeedController({SpeedTest? test}) : _test = test ?? SpeedTest();

  final SpeedTest _test;

  /// Har [start] da oshiriladi. Bekor qilingan o'lchovning kechikkan
  /// javobi yangi natijani buzmasin (app_controller.dart dagi naqsh).
  int _gen = 0;

  SpeedState _state = SpeedState.idle;
  SpeedState get state => _state;

  SpeedResult? _result;
  SpeedResult? get result => _result;

  String? _error;
  String? get error => _error;

  /// O'lchovni boshlaydi: javob vaqti → yuklab olish → yuklash.
  /// Har bosqichda holat o'zgaradi va [notifyListeners] chaqiriladi.
  /// Biror bosqich xato qaytarsa — [SpeedState.failed] va to'xtash.
  Future<void> start() async {
    final int gen = ++_gen;
    _result = null;
    _error = null;

    _set(gen, SpeedState.ping);
    final Result<int> ping = await _test.ping();
    if (gen != _gen) return;
    if (!ping.ok) return _fail(gen, ping.error);

    _set(gen, SpeedState.download);
    final Result<double> down = await _test.download();
    if (gen != _gen) return;
    if (!down.ok) return _fail(gen, down.error);

    _set(gen, SpeedState.upload);
    final Result<double> up = await _test.upload();
    if (gen != _gen) return;
    if (!up.ok) return _fail(gen, up.error);

    _result = SpeedResult(
      pingMs: ping.data!,
      downloadMbps: down.data!,
      uploadMbps: up.data!,
    );
    _set(gen, SpeedState.done);
  }

  /// O'lchovni to'xtatadi va idle ga qaytaradi. Davom etayotgan so'rov
  /// _gen o'zgargani uchun natija bermaydi; oqim [SpeedTest.close] bilan
  /// uziladi.
  void cancel() {
    _gen++;
    _test.close();
    _result = null;
    _error = null;
    _state = SpeedState.idle;
    notifyListeners();
  }

  void _set(int gen, SpeedState next) {
    if (gen != _gen) return;
    _state = next;
    notifyListeners();
  }

  void _fail(int gen, String? message) {
    if (gen != _gen) return;
    _error = message;
    _state = SpeedState.failed;
    notifyListeners();
  }

  @override
  void dispose() {
    _test.close();
    super.dispose();
  }
}
