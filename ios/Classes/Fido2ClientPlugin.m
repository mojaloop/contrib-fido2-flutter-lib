#import "Fido2ClientPlugin.h"
#if __has_include(<fido2_client/fido2_client-Swift.h>)
#import <fido2_client/fido2_client-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fido2_client-Swift.h"
#endif

@implementation Fido2ClientPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFido2ClientPlugin registerWithRegistrar:registrar];
}
@end
