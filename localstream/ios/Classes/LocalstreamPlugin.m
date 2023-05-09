#import "LocalstreamPlugin.h"
#if __has_include(<localstream/localstream-Swift.h>)
#import <localstream/localstream-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "localstream-Swift.h"
#endif

@implementation LocalstreamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLocalstreamPlugin registerWithRegistrar:registrar];
}
@end
