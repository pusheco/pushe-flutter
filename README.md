# Pushe flutter

A plugin to use Pushe sdk in Flutter framework.

### Run the sample

Run: `git clone https://github.com/pusheco/pushe-flutter.git`<br>
The go to example: `cd example`<br>
And run the example on a connected device: `flutter run`<br>

## Installation

Add the plugin to `pubspec.yaml`:

```yaml
dependencies:
  pushe: ^version
```
<img src="https://img.shields.io/badge/release-v1.2-blue"></img>

Then run `flutter packages get` to sync the libraries.

### Set up credentials

Go to https://console.pushe.co , create an application with the same package name and get the manifest tag. Add the manifest tag in the `Application` tag. It should be something like this:

```xml
<meta-data android:name="pushe_token"
           android:value="PUSHE_TOKEN" />
```

### Add the code snippets

In your `main.dart`:

```dart
import 'package:pushe_flutter/pushe.dart';
```

## More Info
For more details, visit [HomePage docs](https://docs.pushe.co/)
