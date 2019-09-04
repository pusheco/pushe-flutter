# Pushe flutter

A plugin to use Pushe sdk in Flutter framework.

### Run the sample

Run: `git clone https://github.com/pusheco/flutter-sample.git`<br>
The go to example: `cd example`<br>
And run the example on a connected device: `flutter run`<br>

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
### More

#### Topics

You can add a user to a specific group. In order to do this you need to use **topics**. To subscribe a user to a topic:

```dart
Pushe.subscribe("topic_name");
```
And to undo this:

```dart
Pushe.unsubscribe("topic_name");
```

#### PusheId

`Pushe id` is an id that makes a device unique and can be used to identifiy devices (users) and not app users. To get that id:

```dart
Pushe.getPusheId().then((pusheId) {
  // Deal with id
});
```

#### Check initialization of Pushe

If you want to see wether pushe is registered to server or not:

```dart
Pushe.isPusheIntialized().then(isIt => print('Is it? $isIt'));
```

#### Notification listeners

To listen to different event of a notification (such as receive, click, etc), you can use this codes:

```dart

// First make the sdk listen
Pushe.initializeNotificationListeners(); // let the input arg be default for now.

// Then add the codes

Pushe.setOnNotificationReceived((notification) {
      // Called when notification was received
});
    
Pushe.setOnNotificationClicked((notification) {
      // Called when notification was clicked
});
    
Pushe.setOnNotificationDismissed((notification) {
      // Called when notification was dismissed
});

Pushe.setOnNotificationCustomContentReceived((notification) {
      // Called when notification custom content was received
});
    
Pushe.setOnNotificationButtonClicked((notification, clickedButton) {

});
```

#### Use it along with FireBase messaging

If you also use firebase messaging plugin at your project, you might have problems receiving and sometimes losing the message.<br>
Since Pushe uses FCM and one app can only have one firebase service, using both is not possible unless you do this:

1. Remove Pushe service from your AndroidManifest tree using this code (add it to `application` block):

```xml
<service
   android:name="co.ronash.pushe.fcm.FcmService" 
   tools:node="remove" />
```

> Make sure `xmlns:tools="http://schemas.android.com/tools"` exists in the manifest tag attributes. Otherwise **tools** is not known to app.

2. Remove firebase messaging service too:

```xml
<service
   android:name="io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService" 
   tools:node="remove" />
```

3. Instead, add this tag to the AndroidManifest too let the Plugin handle both messaging services and make them work together.

```xml
<service android:name="co.ronash.pushe.flutter.PusheFcmService">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```
**Note**: Callbacks only work when app is not fully closed and flutter is still running under the hood. So when app is not opened or force stopped, listeners will not be called.

## More Info
For detailed documentations visit https://pushe.co/docs/flutter/


## Contribution

Feel free to add anything you think is suitable to be in this sample.<br>
It does not follow any specific code style. So just read the code a little bit and send a pull request at anytime. We'll be happy :D.

## Support 
#### Email:
If you have any problem, please contact us using this email, we will get back to you right away:
`support [at] pushe.co`
