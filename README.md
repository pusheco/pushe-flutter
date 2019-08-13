# Pushe flutter

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

## More Info
For detailed documentations visit https://pushe.co/docs/flutter/


## Contribution

Feel free to add anything you think is suitable to be in this sample.<br>
It does not follow any specific code style. So just read the code a little bit and send a pull request at anytime. We'll be happy :D.

## Support 
#### Email:
If you have any problem, please contact us using this email, we will get back to you right away:
`support [at] pushe.co`
