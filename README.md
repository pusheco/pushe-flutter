# Pushe flutter

[Pushe](https://pushe.co) notification service official plugin for Flutter.

## Installation

Add the plugin to `pubspec.yaml`:

```yaml
dependencies:
  pushe_flutter: $latest
```
* If you want to use the latest version, not necessarily released, you can use the github source code.

```yaml
pushe_flutter:
  git:
    url: https://github.com/pusheco/pushe-flutter.git
```

Then run `flutter packages get` to sync the libraries.

### Set up credentials

Go to https://console.pushe.co , create an application with the same package name and get the manifest tag. Add the manifest tag in the `Application` tag. It should be something like this:

```xml
<meta-data android:name="pushe_token"
           android:value="PUSHE_TOKEN" />
```

Run the project after and you should be able to see your device in [console](https://console.pushe.co) after a short time.

### Add the code snippets

In your `main.dart`:

```dart
import 'package:pushe_flutter/pushe.dart';
```

## More Info

* For more details, visit [HomePage docs](https://docs.pushe.co/)
* FAQ and issues in [Github repo](https://github.com/pusheco/pushe-flutter/issues?q=is%3Aissue+).
* Sample project is in the library source code and in the [Sample repo on github](https://github.com/pusheco/pushe-flutter-sample)
