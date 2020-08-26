# Pushe flutter

**Pushe** notification service official plugin for Flutter. Pushe is a push notification service. Refer to [Pushe Homepage](https://pushe.co) for more information.

> **NOTE**: **iOS** features are still in development. Current version does not support iOS.

## Installation

Add the plugin to `pubspec.yaml`:

[![pub package](https://img.shields.io/pub/v/pushe_flutter)](https://pub.dartlang.org/packages/pushe_flutter)

```yaml
dependencies:
  pushe_flutter: ^2.2.0
```

* If you want to use the latest version, not necessarily released and stable, you can directly use the source code on Github.

```yaml
pushe_flutter:
  git:
    url: https://github.com/pusheco/pushe-flutter.git
```

## How to use Pushe

Then run `flutter packages get` to sync the libraries.


### Set up credentials
#### Android:
* Go to [Pushe console](https://console.pushe.co)
* Create an application
* Copy the credentials. An XML `meta-data` tag like below:

```xml
<meta-data android:name="pushe_token"
           android:value="PUSHE_TOKEN" />
```
* Paste it into `Appliacation` tag of the **AndroidManifest.xml** file in the following directory:
> `android/app/src/main/AndroidManifest.xml`

Example:
```xml
<application>
    <!-- Other tags -->
    <meta-data android:name="pushe_token"
           android:value="PUSHE_TOKEN" />
</application>
```

Run the project after and you should be able to see your device id in [console](https://console.pushe.co) after a short time.

#### iOS:
> Soon...

---

Visit the [**Documentation**](https://docs.pushe.co/docs/flutter/intro/) for API references.

## More Info

* FAQ and issues in [Github repo](https://github.com/pusheco/pushe-flutter/issues?q=is%3Aissue+)
* Sample project is in the library source code and in the [Sample repo on github](https://github.com/pusheco/pushe-flutter-sample)
