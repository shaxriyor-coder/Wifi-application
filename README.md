# WiFi App

> A Flutter prototype for discovering and managing a supported Huawei
> EchoLife HG8245H5 router from an Android phone on the same Wi-Fi network.

The app guides the user from local-network detection to router authentication,
then provides focused tools for changing Wi-Fi settings and viewing connected
device names. The interface is currently in Uzbek.

**Project status:** portfolio/demo project, not a Play Store release.
The router's management interface uses plain HTTP, so credentials and session
cookies are not encrypted in transit. See [Security](#security) before use.

## Demo

1. Connect an Android phone to the supported router's Wi-Fi.
2. The app detects the active network and checks the local gateway for the
   HG8245H5 administration page.
3. Enter the router administrator credentials yourself. The app does not
   contain or try a default username/password.
4. View the current Wi-Fi name, change the SSID or password, or inspect names
   of online devices reported by the router.

### Short code walkthrough

After authentication, the settings screen validates the new SSID before
applying it. This excerpt uses the controller methods wired to the app UI:

```dart
controller.goToSsidEdit();

const newSsid = 'HomeNetwork_5G';
if (controller.validate(newSsid) == null) {
  await controller.apply(newSsid);
}
```

`AppController` validates the name again before making the router request, so
the update is guarded at both the UI and action boundary.

## Features

- Detects Wi-Fi, mobile data, and no-network states on Android.
- Reads the active network's default IPv4 gateway and screens for common phone
  hotspot address ranges.
- Identifies the supported router by checking its administration-page response.
- Requests router credentials from the user; no built-in credentials are tried.
- Reads and changes the Wi-Fi network name (SSID) and password.
- Displays online device names without showing their MAC or IP addresses.
- Validates SSID and password input before submitting changes.

Router management is currently implemented only for the Huawei EchoLife
HG8245H5. Other models, IPv6 gateways, and router management on iOS, desktop,
or web are not supported. A standalone speed-test module exists in the source
but is not connected to the app UI.

## How it works

```text
Flutter screens
    │ user actions and rendered state
    ▼
AppController ── AppState
    ├── EntryCheck ── NetworkInfo ── MethodChannel ── Android NetworkPlugin
    └── HuaweiHg8245h5 adapter ── local router HTTP endpoints
         ├── login and session cookie
         ├── WLAN settings read/update
         └── connected device list
```

### Key implementation decisions

- **Separation of concerns:** screens render state, `AppController` coordinates
  workflows, and `HuaweiHg8245h5` contains model-specific router requests.
- **Explicit state machine:** connectivity, login, loading, success, and error
  paths have distinct states rather than being inferred from widget state.
- **Stale-response protection:** generation counters stop older async responses
  from overwriting the result of a newer action.
- **Injectable boundaries:** controllers and HTTP-backed classes accept
  dependencies, which makes the core flow easier to test in isolation.
- **Typed outcomes:** network and router operations return `Result<T>` values
  for explicit success or failure.
- **Input validation:** SSID and password rules are checked before a
  configuration change is sent.

## Project structure

| Path | Responsibility |
| --- | --- |
| `lib/main.dart` | App entry point and state-to-screen mapping |
| `lib/app_controller.dart` | Application workflow and state transitions |
| `lib/models/` | App states and typed operation results |
| `lib/network/entry_check.dart` | Connectivity, gateway, and router discovery |
| `lib/network/network_info.dart` | Dart interface to Android network methods |
| `lib/adapters/huawei_hg8245h5.dart` | Router login, response parsing, and WLAN operations |
| `lib/screens/` | User interface for app states and actions |
| `lib/validation/` | SSID and Wi-Fi password validation |
| `android/app/src/main/kotlin/com/example/wifi_app/` | Android platform-channel implementation |

## Run locally

### Requirements

- Flutter SDK and a Dart SDK compatible with `sdk: ^3.12.1` in `pubspec.yaml`
- Android phone and Huawei EchoLife HG8245H5 on the same Wi-Fi network
- Router administrator credentials

```sh
flutter pub get
flutter analyze
flutter run
```

There is no project-specific automated test suite yet. Validate router
operations only on hardware and a network you own or are authorized to
administer. A successful Flutter build alone does not verify router behavior.

## Security

- **Unencrypted router traffic:** the adapter uses `http://` because the
  supported router exposes its management interface over HTTP. Credentials,
  session cookies, and configuration data may be observed or modified by
  someone who can monitor the local network. Base64-encoding a password is
  not encryption.
- **User-supplied credentials:** credentials are entered by the user and held
  in memory for the active session; the app does not intentionally persist
  them. In-memory handling does not protect the HTTP connection.
- **Use on trusted networks only:** do not use this prototype on public Wi-Fi
  or to administer a router without authorization.
- **Ambiguous change result:** changing an SSID or password can disconnect the
  phone before a response arrives. The adapter treats some connection errors
  during a change as success, so it cannot always verify the router applied
  the change.
- **Firmware-specific parsing:** the adapter depends on Huawei HTML/JavaScript
  response formats and WPA/WPA2-PSK settings. Other firmware or security modes
  may not work.
- **Not ready for Play Store:** the Android package ID is still
  `com.example.wifi_app`, and the release build uses debug signing. Publishing
  requires a publisher-owned package ID, protected release signing, device and
  firmware validation, a privacy policy, and a Play Console Data safety
  declaration.

## Roadmap

- Add automated tests for state transitions, validation, and router-response
  parsing.
- Test against documented router firmware versions and failure cases.
- Resolve the plain-HTTP transport risk before any app-store release.
- Complete production Android identity, signing, privacy, and release setup.

## License

No license has been selected. Public visibility on GitHub does not grant
permission to reuse or redistribute this project.
