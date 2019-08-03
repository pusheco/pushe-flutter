## 0.0.1

* Pushe basic commands.

```
initialize
getPusheId
subscribe
unsubscribe
setNotificationOff
setNotificationOn
isPusheInitialized
sendSimpleNotifToUser
sendAdvancedNotifToUser
initializeNotificationListeners
setOnNotificationReceived
setOnNotificationClicked
setOnNotificationButtonClicked
setOnNotificationCustomContentReceived
setOnNotificationDismissed
```
* Support for Android OS.

* Notification content callback.

**Note**: Callbacks will be passed when flutter is running. So when the app is closed, notifications will not call the callback methods (They actually will, but the flutter doesn't get it).
