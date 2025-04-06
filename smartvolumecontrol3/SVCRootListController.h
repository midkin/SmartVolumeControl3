



#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../SVCHelperController.h"




@interface SVCRootListController : PSListController
@end

@interface SVCHapticListController : PSListController
@end




@interface PSListItemsController : PSListController
@end
@interface SVCPSListItemsController : PSListItemsController
@end









@interface PSSpecifier ()
@property (nonatomic, retain) NSArray * values;
-(PSSpecifier *)initWithName:(NSString *)name target:(PSListController *)controller set:(SEL)setter get:(SEL)getter detail:(Class)className cell:(long long)type edit:(Class)edit;
-(void)setKeyboardType:(long long)type autoCaps:(long long)caps autoCorrection:(long long)autocorrect;
@end

@interface UIImage ()
+(instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@interface UIDevice ()
-(NSString *)_deviceInfoForKey:(CFStringRef)key;
@end

@interface WKWebView : UIView
-(id)loadRequest:(NSURLRequest *)request;
-(void)stopLoading;
-(id)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)url;
@end

@interface UIButton ()
-(void)_setButtonType:(long long)type;
@end

@interface CALayer ()
-(void)setContinuousCorners:(BOOL)continuous;
@end