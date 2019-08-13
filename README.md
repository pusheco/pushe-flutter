# Pushe

A plugin to use Pushe sdk in Flutter framework.

## Installation

Add the plugin to `pubspec.yaml`:

```yaml
dependencies:
  pushe: ^version
```
<img src="https://img.shields.io/github/release/pusheco/flutter-sample"></img>

Then run `flutter packages get` to sync the libraries.

### Set up credentials

Go to https://console.pushe.co , create an application with the same package name and get the manifest tag. Add the manifest tag in the `Application` tag. It should be something like this:

```xml
<meta-data android:name="co.ronash.pushe.token"
           android:value="PUSHE_12345678" />
```

### Add the code snippets

In your `main.dart`:

```dart
import 'package:pushe/pushe.dart';
```

```dart
Pushe.initialize();
```

* More documentation in progress...
