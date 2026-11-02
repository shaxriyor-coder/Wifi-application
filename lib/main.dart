import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models/app_state.dart';
import 'screens/applying_screen.dart';
import 'screens/checking_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/hotspot_screen.dart';
import 'screens/key_edit_screen.dart';
import 'screens/logging_in_screen.dart';
import 'screens/login_help_screen.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/mobile_data_screen.dart';
import 'screens/no_network_screen.dart';
import 'screens/result_screen.dart';
import 'screens/ssid_edit_screen.dart';
import 'screens/unreachable_screen.dart';
import 'screens/unsupported_screen.dart';

void main() {
  runApp(const WifiApp());
}

class WifiApp extends StatefulWidget {
  const WifiApp({super.key});

  @override
  State<WifiApp> createState() => _WifiAppState();
}

class _WifiAppState extends State<WifiApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _controller.addListener(_onChanged);
    _controller.start();
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _screenFor(_controller.state),
    );
  }

  /// §5 — har bir holat aniq yozilgan, `default` yo'q. Yangi holat
  /// qo'shilsa switch to'liq bo'lmay qoladi va kompilyator ogohlantiradi.
  Widget _screenFor(AppState state) {
    switch (state) {
      case AppState.checking:
        return const CheckingScreen();
      case AppState.noNetwork:
        return NoNetworkScreen(controller: _controller);
      case AppState.mobileData:
        return MobileDataScreen(controller: _controller);
      case AppState.hotspot:
        return HotspotScreen(controller: _controller);
      case AppState.unreachable:
        return UnreachableScreen(controller: _controller);
      case AppState.unsupported:
        return const UnsupportedScreen();
      case AppState.needLogin:
        return LoginScreen(controller: _controller);
      case AppState.loginHelp:
        return LoginHelpScreen(controller: _controller);
      case AppState.loggingIn:
        return const LoggingInScreen();
      case AppState.loginFailed:
        return LoginScreen(controller: _controller);
      case AppState.menu:
        return MenuScreen(controller: _controller);
      case AppState.devicesLoading:
        return DevicesScreen(controller: _controller);
      case AppState.devices:
        return DevicesScreen(controller: _controller);
      case AppState.devicesFailed:
        return DevicesScreen(controller: _controller);
      case AppState.ssidEdit:
        return SsidEditScreen(controller: _controller);
      case AppState.keyEdit:
        return KeyEditScreen(controller: _controller);
      case AppState.applying:
        return const ApplyingScreen();
      case AppState.success:
        return ResultScreen(controller: _controller);
      case AppState.failure:
        return ResultScreen(controller: _controller);
    }
  }
}
