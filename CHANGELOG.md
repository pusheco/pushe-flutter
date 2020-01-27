## 2.0.0

* Migrate to the new Plus sdk of Pushe
* Get used of new Plus features in the SDK
* No initialization is needed for the library
> Notice the `setNotificationListener` is not fully reliable yet, since it does not handle background

## 1.1.0-alpha1

* Fixed Battery usage issue
* Added method `isNotificationOn`

## 1.0.1

* Fix problem with AndroidX projects.

* Changed example package name.

## 1.0.0

* Release ready version.

* New listener API for notification callbacks.

* Removed extra files and APIs.

* Remove extra Fcm service. Firebase and other services can now be added and supported natively.

* Minor improvements and bug fixes.

## 0.9.1

* Recreating notification callbacks. Callbacks will return actual notification objects now.

* From now on, Plugin can be used along with Firebase messaging plugin.

* Minor improvements and bug fixes.

## 0.2.1

* Added better styled callbacks.

* Minor improvements.

## 0.0.2

* Bug fixed on notification listeners not getting called.

* Fixed a little bug in example app.

* Listeners of notification callbacks are working.

* Added Release offline AAR package.

* More comments in plugin.

## 0.0.1

* Pushe basic commands.

* Support for Android OS.

* Notification content callback.

**Note**: Callbacks will be passed when flutter is running. So when the app is closed, notifications will not call the callback methods (They actually will, but the flutter doesn't get it).