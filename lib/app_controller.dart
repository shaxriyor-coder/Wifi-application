import 'package:flutter/widgets.dart';

import 'adapters/huawei_hg8245h5.dart';
import 'models/app_state.dart';
import 'models/result.dart';
import 'network/entry_check.dart';
import 'network/network_info.dart';
import 'validation/key_rules.dart';
import 'validation/ssid_rules.dart';

/// success va failure ekranlari qaysi amal haqida ekanini shundan biladi.
enum LastAction { ssid, key }

/// Holat mashinasi: router tekshiruvi, foydalanuvchi login'i va amallar.
///
/// [EntryCheck], [HuaweiHg8245h5] va [validateSsid] ni bir joyda bog'laydi.
/// Ekran qatlami faqat [state], [message], [currentSsid] ni o'qiydi va
/// tugma metodlarini chaqiradi.
///
/// §10.3: login/parol hech qayerda saqlanmaydi — bu obyekt yashaganicha
/// xotirada turadi, ilova yopilsa yo'qoladi.
class AppController extends ChangeNotifier with WidgetsBindingObserver {
  AppController({
    EntryCheck? entryCheck,
    NetworkInfo? networkInfo,
    HuaweiHg8245h5 Function(String host)? adapterFactory,
  })  : _entryCheck = entryCheck ?? EntryCheck(),
        _networkInfo = networkInfo ?? const NetworkInfo(),
        _adapterFactory =
            adapterFactory ?? ((String host) => HuaweiHg8245h5(host: host)) {
    WidgetsBinding.instance.addObserver(this);
  }

  final EntryCheck _entryCheck;
  final NetworkInfo _networkInfo;
  final HuaweiHg8245h5 Function(String host) _adapterFactory;

  AppState _state = AppState.checking;
  AppState get state => _state;

  /// Ekranda ko'rsatiladigan xato yoki izoh matni (o'zbekcha). Yo'q bo'lsa null.
  String? _message;
  String? get message => _message;

  /// Login o'tgach routerdan o'qilgan joriy tarmoq nomi. `validateSsid`
  /// bir xillikni shu bilan tekshiradi.
  String _currentSsid = '';
  String get currentSsid => _currentSsid;

  /// Login o'tgach routerdan o'qilgan joriy parol. Faqat `validateKey`
  /// bilan solishtirish uchun xotirada turadi; hech qayerga yozilmaydi,
  /// saqlanmaydi va ekranga chiqarilmaydi.
  String _currentKey = '';

  /// success va failure ekranlari qaysi amal (nom yoki parol) haqida
  /// ekanini shundan bilishadi.
  LastAction? _lastAction;
  LastAction? get lastAction => _lastAction;

  HuaweiHg8245h5? _adapter;

  /// devices ekranida ko'rsatilgan oxirgi ro'yxat. `goToDevices` va
  /// `_runEntryCheck` boshida tozalanadi — eski ma'lumot ekranga
  /// sizib chiqmasligi uchun.
  List<LanDevice> _devices = <LanDevice>[];

  /// devices ekrani o'qiydigan ro'yxat: faqat online qurilmalar,
  /// nomlilar oldin (routerdan kelgan tartibda), nomsizlar keyin.
  /// MAC hech qayerda log qilinmaydi.
  List<LanDevice> get deviceList {
    final online = _devices.where((d) => d.online);
    return [
      ...online.where((d) => d.name.isNotEmpty),
      ...online.where((d) => d.name.isEmpty),
    ];
  }

  /// Har bir asinxron oqim boshida oshiriladi. Fondan qaytish yoki yangi
  /// urinish eski oqimning kechikkan javobini bekor qiladi (§5: taymer yo'q,
  /// lekin kechikkan javob eski holatga qaytarmasligi kerak).
  int _gen = 0;

  bool _started = false;

  // --------------------------------------------------------- tashqi API

  /// Ilova ochilganda bir marta chaqiriladi.
  Future<void> start() {
    _started = true;
    return _runEntryCheck();
  }

  /// noNetwork / mobileData / hotspot / unreachable / unsupported / failure
  /// ekranlaridagi "Qayta urinish" tugmasi (§6.4). Fondan qaytish buni
  /// avtomatik bajaradi, tugma kech ulanish holatlari uchun.
  Future<void> retry() => _runEntryCheck();

  /// noNetwork / mobileData ekranlaridagi "Wi-Fi sozlamalari" tugmasi.
  Future<void> openWifiSettings() => _networkInfo.openWifiSettings();

  /// Login ekranidan foydalanuvchi kiritgan juftlik.
  Future<void> submitLogin(String username, String password) {
    final int gen = ++_gen;
    return _login(username: username, password: password, gen: gen);
  }

  /// needLogin / loginFailed ekranidagi "Ma'lumotlarni bilmayapsizmi?"
  /// tugmasi — kirish ma'lumotlari haqida yordam matnini ko'rsatadi.
  void goToLoginHelp() {
    if (_state != AppState.needLogin && _state != AppState.loginFailed) return;
    _message = null;
    _setState(AppState.loginHelp);
  }

  /// loginHelp ekranidagi "Ortga" tugmasi — kirish ekraniga qaytaradi.
  void backFromLoginHelp() {
    if (_state != AppState.loginHelp) return;
    _message = null;
    _setState(AppState.needLogin);
  }

  /// menu ekranidagi "Nomni o'zgartirish" tugmasi.
  void goToSsidEdit() {
    if (_state != AppState.menu) return;
    _message = null;
    _setState(AppState.ssidEdit);
  }

  /// menu ekranidagi "Parolni o'zgartirish" tugmasi. devices ekranidagi
  /// "Parolni o'zgartirish" tugmasi ham shu yerga keladi — notanish
  /// qurilmani tushirishning yagona ishonchli yo'li.
  void goToKeyEdit() {
    if (_state != AppState.menu && _state != AppState.devices) return;
    _message = null;
    _setState(AppState.keyEdit);
  }

  /// menu ekranidagi "Ulangan qurilmalar" tugmasi. Ro'yxat bir marta
  /// yuklanadi — avtomatik yangilanish yo'q. Qayta yuklash uchun
  /// foydalanuvchi bu metodni yana chaqiradi (retry tugmasi).
  Future<void> goToDevices() async {
    if (_state != AppState.menu &&
        _state != AppState.devices &&
        _state != AppState.devicesFailed) {
      return;
    }

    final HuaweiHg8245h5? adapter = _adapter;
    if (adapter == null) {
      _setState(AppState.devicesFailed);
      return;
    }

    final int gen = ++_gen;
    _message = null;
    _devices = <LanDevice>[];
    _setState(AppState.devicesLoading);

    final Result<List<LanDevice>> res = await adapter.listDevices();
    if (gen != _gen) return;

    if (res.ok) {
      _devices = res.data!;
      _message = null;
      _setState(AppState.devices);
    } else {
      _message = res.error;
      _setState(AppState.devicesFailed);
    }
  }

  /// ssidEdit ekranidagi maydonni tekshirish. `null` qaytsa tugma faol (§11).
  String? validate(String name) => validateSsid(name, _currentSsid);

  /// ssidEdit ekranidagi "O'zgartirish" tugmasi.
  Future<void> apply(String name) async {
    if (_state != AppState.ssidEdit) return;

    final String? error = validate(name);
    if (error != null) {
      _message = error;
      notifyListeners();
      return;
    }

    final HuaweiHg8245h5? adapter = _adapter;
    if (adapter == null) {
      _setState(AppState.failure);
      return;
    }

    final int gen = ++_gen;
    _message = null;
    _lastAction = LastAction.ssid;
    _setState(AppState.applying);

    final Result<void> res = await adapter.changeSsid(name);
    if (gen != _gen) return;

    if (res.ok) {
      _currentSsid = name;
      _message = null;
      _setState(AppState.success);
    } else {
      _message = res.error;
      _setState(AppState.failure);
    }
  }

  /// keyEdit ekranidagi maydonlarni tekshirish. `null` qaytsa tugma faol (§4).
  String? validateKeyInput(String newKey, String confirmKey) =>
      validateKey(newKey, confirmKey, _currentKey);

  /// keyEdit ekranidagi "O'zgartirish" tugmasi.
  Future<void> applyKey(String newKey, String confirmKey) async {
    if (_state != AppState.keyEdit) return;

    final String? error = validateKeyInput(newKey, confirmKey);
    if (error != null) {
      _message = error;
      notifyListeners();
      return;
    }

    final HuaweiHg8245h5? adapter = _adapter;
    if (adapter == null) {
      _setState(AppState.failure);
      return;
    }

    final int gen = ++_gen;
    _message = null;
    _lastAction = LastAction.key;
    _setState(AppState.applying);

    final Result<void> res = await adapter.changePassword(newKey);
    if (gen != _gen) return;

    if (res.ok) {
      _currentKey = newKey;
      _message = null;
      _setState(AppState.success);
    } else {
      _message = res.error;
      _setState(AppState.failure);
    }
  }

  /// failure / devices / devicesFailed / ssidEdit / keyEdit ekranlaridagi
  /// "Ortga" tugmasi — foydalanuvchini menu ga qaytaradi.
  void backToMenu() {
    if (_state != AppState.failure &&
        _state != AppState.devices &&
        _state != AppState.devicesFailed &&
        _state != AppState.ssidEdit &&
        _state != AppState.keyEdit) {
      return;
    }
    _message = null;
    _devices = <LanDevice>[];
    _setState(AppState.menu);
  }

  // --------------------------------------------------------- ichki oqim

  Future<void> _runEntryCheck() async {
    final int gen = ++_gen;
    _message = null;
    _currentSsid = '';
    _currentKey = '';
    _lastAction = null;
    _devices = <LanDevice>[];
    _disposeAdapter();
    _setState(AppState.checking);

    final EntryCheckResult result = await _entryCheck.run();
    if (gen != _gen) return;

    switch (result.state) {
      case EntryState.noNetwork:
        _setState(AppState.noNetwork);
        return;
      case EntryState.mobileData:
        _setState(AppState.mobileData);
        return;
      case EntryState.hotspot:
        _setState(AppState.hotspot);
        return;
      case EntryState.unreachable:
        _setState(AppState.unreachable);
        return;
      case EntryState.unsupported:
        _setState(AppState.unsupported);
        return;
      case EntryState.loginRequired:
        break;
    }

    final String? gateway = result.gateway;
    if (gateway == null) {
      // loginRequired doim gateway bilan keladi; himoya uchun.
      _setState(AppState.unreachable);
      return;
    }

    _adapter = _adapterFactory(gateway);
    _setState(AppState.needLogin);
  }

  /// Routerga faqat foydalanuvchi kiritgan ma'lumotlar bilan kiradi.
  Future<void> _login({
    required String username,
    required String password,
    required int gen,
  }) async {
    final HuaweiHg8245h5? adapter = _adapter;
    if (adapter == null) {
      _setState(AppState.unreachable);
      return;
    }

    _message = null;
    _setState(AppState.loggingIn);

    final Result<void> login = await adapter.login(username, password);
    if (gen != _gen) return;

    if (!login.ok) {
      _message = login.error;
      _setState(AppState.loginFailed);
      return;
    }

    // Login o'tdi — joriy SSID ni o'qiymiz. Tarmoq va router allaqachon
    // tasdiqlangan, shuning uchun bu yerdagi xato → failure.
    final Result<WlanConfig> cfg = await adapter.readWlanConfig();
    if (gen != _gen) return;

    if (!cfg.ok) {
      _message = cfg.error;
      _setState(AppState.failure);
      return;
    }

    _currentSsid = cfg.data!.ssid;
    _currentKey = cfg.data!.preSharedKey;
    _message = null;
    _setState(AppState.menu);
  }

  // --------------------------------------------------------- yordamchi

  void _setState(AppState next) {
    _state = next;
    notifyListeners();
  }

  void _disposeAdapter() {
    _adapter?.close();
    _adapter = null;
  }

  // --------------------------------------------------- hayot sikli (§5.3)

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (_started && lifecycle == AppLifecycleState.resumed) {
      _runEntryCheck();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAdapter();
    _entryCheck.close();
    super.dispose();
  }
}
