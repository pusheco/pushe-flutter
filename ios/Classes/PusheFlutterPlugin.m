#import "PusheFlutterPlugin.h"
#if __has_include(<pushe_flutter/pushe_flutter-Swift.h>)
#import <pushe_flutter/pushe_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pushe_flutter-Swift.h"
#endif

@implementation PusheFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPusheFlutterPlugin registerWithRegistrar:registrar];
}
@end
