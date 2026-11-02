import 'package:flutter/services.dart';

/// Joriy ulanish turi. `getNetworkType` shu enum'ni qaytaradi.
enum NetworkType { wifi, mobile, none }

/// `wifi_app/network` MethodChannel'ini o'raydigan klass.
///
/// Native tomon (NetworkPlugin.kt) tayyor va real qurilmada sinalgan.
/// Bu yerda hech qanday soxta qiymat yo'q: ma'lumot olinmasa yoki kanal
/// javob bermasa `none` yoki `null` qaytariladi.
class NetworkInfo {
  const NetworkInfo();

  static const MethodChannel _channel = MethodChannel('wifi_app/network');

  /// "wifi" / "mobile" / "none" -> [NetworkType]. Xatoda [NetworkType.none].
  Future<NetworkType> getNetworkType() async {
    try {
      final String? raw = await _channel.invokeMethod<String>('getNetworkType');
      switch (raw) {
        case 'wifi':
          return NetworkType.wifi;
        case 'mobile':
          return NetworkType.mobile;
        default:
          return NetworkType.none;
      }
    } on PlatformException {
      return NetworkType.none;
    } on MissingPluginException {
      return NetworkType.none;
    }
  }

  /// Default route gateway IP'si, masalan "192.168.100.1".
  /// Topilmasa yoki xatoda `null`.
  Future<String?> getGatewayIp() async {
    try {
      return await _channel.invokeMethod<String>('getGatewayIp');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Tizimning Wi-Fi sozlamalari oynasini ochadi. Xato yutib yuboriladi.
  Future<void> openWifiSettings() async {
    try {
      await _channel.invokeMethod<void>('openWifiSettings');
    } on PlatformException {
      // e'tiborsiz qoldiriladi
    } on MissingPluginException {
      // e'tiborsiz qoldiriladi
    }
  }

  /// Tizimning simsiz aloqa sozlamalari oynasini ochadi. Xato yutib yuboriladi.
  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } on PlatformException {
      // e'tiborsiz qoldiriladi
    } on MissingPluginException {
      // e'tiborsiz qoldiriladi
    }
  }
}
