# WiFi App

**WiFi App** is a Flutter prototype for checking and managing a supported
Huawei EchoLife HG8245H5 home router from an Android phone connected to the
same Wi-Fi network. The user interface is currently in Uzbek.

The project demonstrates a complete, model-specific router workflow: discover
the local gateway, identify a supported router, request administrator
credentials from the user, read current WLAN settings, and apply a validated
SSID or password change.

> **Status: prototype, not a Play Store release.** Router administration uses
> plain HTTP because the supported router exposes its management interface
> over HTTP. Credentials and session cookies are therefore not protected by
> transport encryption. Read [Security and limitations](#security-and-limitations)
> before using the app.

## What the app does

- Detects whether Android is using Wi-Fi, mobile data, or no active network.
- Reads the active network's default IPv4 gateway and screens for known phone
  hotspot address ranges.
- Checks the gateway's administration page for the HG8245H5 model identifier.
- Prompts the user for the router administrator's username and password.
  **No default router credentials are embedded or tried automatically.**
- Reads the current SSID and Wi-Fi password after a successful router login.
- Changes the SSID or Wi-Fi password after validating the user's input.
- Lists online devices reported by the router; the UI displays device names,
  not MAC or IP addresses.

The router-management path is implemented only for the Huawei EchoLife HG8245H5.
Other router models, IPv6 gateways, and router management on iOS, desktop, or
web are not supported. The speed-test implementation is present in the source
but is not connected to the current app interface.

## User and network flow

1. **Check connectivity.** The Android platform channel reports the active
   network type and default IPv4 gateway.
2. **Find a supported router.** The app rejects known phone-hotspot ranges,
   requests `http://<gateway>/`, and checks the response for `HG8245H5`.
3. **Request administrator credentials.** The user enters the router
   administrator login. The app does not guess or retry built-in credentials.
4. **Authenticate and read WLAN settings.** The adapter obtains the router's
   login token, submits the user-provided credentials, then parses the router
   configuration page.
5. **Choose an action.** The user can view the current SSID, change the network
   name, change the Wi-Fi password, or view online device names.
6. **Validate and apply.** Input is validated before the adapter posts the
   updated WLAN configuration. A router change can disconnect the phone, so
   the final result may not be independently verifiable.

The app checks reachability of the local router; it does not require or test
internet access as part of router discovery.

## Architecture

```text
Android UI (Flutter screens)
            │ user actions / rendered state
            ▼
       AppController ─────────────── AppState
            │
            ├── EntryCheck ── NetworkInfo ── MethodChannel ── NetworkPlugin.kt
            │       └──────── gateway HTTP model check
            │
            └── HuaweiHg8245h5 adapter ── router HTTP endpoints
                    ├── login and session cookie
                    ├── WLAN settings read/update
                    └── connected device list
```

### Source layout

| Path | Responsibility |
| --- | --- |
| `lib/main.dart` | App entry point and exhaustive state-to-screen mapping |
| `lib/app_controller.dart` | Coordinates discovery, login, actions, and lifecycle changes |
| `lib/models/app_state.dart` | Explicit states for loading, errors, and user flows |
| `lib/models/result.dart` | Typed success/failure results |
| `lib/network/entry_check.dart` | Network, gateway, hotspot, and router checks |
| `lib/network/network_info.dart` | Dart wrapper for Android network methods |
| `lib/network/detector.dart` | Supported router model detection |
| `lib/adapters/huawei_hg8245h5.dart` | Huawei-specific login, parsing, and configuration requests |
| `lib/validation/` | SSID and password input rules |
| `lib/screens/` | UI for each app state |
| `android/app/src/main/kotlin/com/example/wifi_app/` | Native connectivity and gateway implementation |

### Design decisions

- **UI and router protocol are separated.** Screens call the controller; the
  Huawei-specific HTTP details stay in one adapter.
- **Network access is injectable.** The controller and HTTP services accept
  dependencies, making isolated tests and alternate implementations possible.
- **Async work is guarded against stale responses.** A generation counter
  prevents an older network request from overwriting a more recent state.
- **Failures are explicit.** Network and router operations return typed
  `Result<T>` values rather than fabricated success data.
- **User input is checked before configuration changes.** SSIDs are limited
  to 32 supported characters; new Wi-Fi passwords must meet the app's
  length, character, confirmation, and unchanged-password rules.

## Build and run

### Requirements

- Flutter SDK with a Dart SDK matching the constraint in `pubspec.yaml`
  (`^3.12.1`)
- Android device and a Huawei EchoLife HG8245H5 on the same Wi-Fi network
- Administrator credentials for that router

```sh
flutter pub get
flutter analyze
flutter run
```

There is no project-specific automated test suite in this repository yet.
Exercise router operations only on hardware and a network you own or are
authorized to administer. A successful generic Flutter build does not verify
the router integration.

## Security and limitations

- **Plain HTTP:** The router API requests use `http://`. Router credentials,
  session cookies, and configuration data can be observed or modified by a
  party able to monitor the local network. Base64-encoding the password in the
  router request is not encryption.
- **Credentials are user-supplied:** The app no longer includes or
  automatically attempts a default router administrator login. Credentials
  are used in memory for the active session and are not intentionally saved by
  the app. In-memory handling does not secure the HTTP transport.
- **Local-network scope:** Use only on a trusted network and with a router you
  are authorized to administer. Avoid public Wi-Fi and untrusted networks.
- **Change confirmation is limited:** The router may disconnect the phone
  before responding after an SSID or password change. The adapter treats some
  connection failures during that operation as success, so the app may not be
  able to confirm whether the router applied the change.
- **Supported firmware is narrow:** The adapter depends on specific Huawei
  HTML/JavaScript response formats and WPA/WPA2-PSK settings. Firmware changes
  or other security modes may cause the operation to fail.
- **Device list privacy:** Device names come from the router and may be
  inaccurate or blank. MAC and IP addresses are parsed for internal filtering
  but are not displayed in the device list.
- **Standalone speed-test code:** If wired into the UI, the speed-test module
  sends test requests to Cloudflare. It is not currently invoked by the app.
- **Not release-ready:** Android still uses the placeholder package ID
  `com.example.wifi_app`, and the Gradle release build uses debug signing.
  A Play Store release also requires a publisher-owned package ID, protected
  release signing, supported-device testing, a privacy policy, and a Play
  Console Data safety declaration.

## Roadmap

- Add automated tests for network-state transitions, input validation, and
  router response parsing.
- Validate the router adapter against documented firmware versions and
  realistic error responses.
- Revisit secure transport and consent before any public app-store release.
- Configure production Android identity, signing, privacy documentation, and
  release verification.

## License

No license has been selected. Public visibility on GitHub does not grant
permission to reuse or redistribute this project.
