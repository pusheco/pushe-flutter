# ChangeLog
## 2.4.0

> **New**
> - PusheFlutter now features iOS support
> - Android supports Huawei push notifications using `hms` module

### Android
- Update native library to `2.4.1-beta05` which includes:
    - `hms` module adding support for sending push notifications on Huawei devices (HMSCore)
    - Improvements and bug fixes

### iOS
- Stable changes of `2.3.0-alpha01`

## 2.3.0-alpha01

> **New**
> PusheFlutter now features iOS support

- [change] Inner plugin classes are changed to respect iOS native classes
- **Android**: Update native library to `2.2.1`


## 2.2.0

- Introducing **InAppMessaging** module added to plugin
- Added APIs:
    * `triggerEvent` for triggering local events.
    * `disableInAppMessaging`/`EnableInAppMessaging`/`isInAppMessagingEnabled` to control whether message should be shown or not.
    * `setInAppMessagingListener` to get a callback when a specific event occurred on InAppMessaging module
    * `dismissShownInApp` to remove shown InApp message using code
    * `testInAppMessage` for testing purposes using code
- **Fix**: Bug in `sendNotificationToUser` when type was `DeviceId`
- **Fix**: PlatformChannel crash after successful `sendNotificationToUser`

## 2.1.1
- Update Native Android dependency to `pushe:2.1.1`
- Custom RxJava is used to avoid large size when not needed
    - If developer or any library is using RxJava, `duplicate` error might be thrown
    In that case you should exclude RxJava and instead implement a normal version
- Added support for GDPR compliance
- Native library has been migrated to AndroidX
- Deprecate `getAndroidId`. Instead, `getDeviceId` should be used

## 2.1.1-alpha01
- Update native dependency to `pushe:2.1.1-beta08`

## 2.1.0

- Added Support for **Flutter Embedding V2**
- Migrate native language to Kotlin
- Added APIs:
    * `createNotificationChannel`
    * `removeNotificationChannel`
    * `enableCustomSound`
    * `DisableCustomSound`
- Improvements on analytics methods `sendEvent` and `sendEcommerceData`
- Added support for background execution to get the callbacks event when the app is fully killed
- Fix bug when clearing `customId`, `userEmail` and `userPhoneNumber`. You can now set null to clear them.

## 2.0.3

- Fix bug in notification listeners
- Improve `sendNotificationToUser` to support multiple IDs
- Function callbacks will have no boolean status anymore, since there was no false status
- Code style improvements
- Example project improvements

## 2.0.2

- Fix issue with AndroidX

## 2.0.1

- Fix formatting of plugin
- Minor improvements

## 2.0.0

* Migrate to the new Plus sdk of Pushe
* Get used of new Plus features in the SDK
* No initialization is needed for the library
> Notice the `setNotificationListener` is not fully reliable yet, since it does not handle background

## 1.1.0-alpha1

* Fixed Battery usage issue
* Added method `isNotificationOn`

## 1.0.1

* Fix problem with **AndroidX** projects.

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