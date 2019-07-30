#import "PushePlugin.h"
#import <pushe/pushe-Swift.h>

@implementation PushePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPushePlugin registerWithRegistrar:registrar];
}
@end
