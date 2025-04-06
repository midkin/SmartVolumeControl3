



#import <Foundation/NSObject.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSData.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLSession.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIImage.h>
#import <objc/runtime.h>




@interface SVCHelperController : NSObject
+(instancetype)sharedInstance;
-(void)licenseCheck;
@end




@interface UIDevice ()
-(NSString *)_deviceInfoForKey:(CFStringRef)key;
+(BOOL)_hasHomeButton;
-(long long)_feedbackSupportLevel;
@end

@interface AVSystemController : NSObject
+(AVSystemController *)sharedAVSystemController;
-(BOOL)getActiveCategoryVolume:(float *)volumePointer andName:(NSString **)name;
-(BOOL)getVolume:(float *)volume forCategory:(NSString *)category;
-(BOOL)changeActiveCategoryVolumeBy:(float)volume;
@end

@interface UIImage ()
+(instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end