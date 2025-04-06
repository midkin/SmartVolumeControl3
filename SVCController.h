




#import <UIKit/UIView.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UILabel.h>
#import <UIKit/UIVisualEffectView.h>
#import <UIKit/UIPanGestureRecognizer.h>
#import <UIKit/UIBezierPath.h>
#import <UIKit/UIScreen.h>
#import <UIKit/UIImpactFeedbackGenerator.h>
#import <UIKit/UISelectionFeedbackGenerator.h>
#import <UIKit/UINotificationFeedbackGenerator.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SVCHelperController.h"




typedef double NSTimeInterval;




@interface SVCController : NSObject
+(instancetype)sharedInstance;
-(void)releaseObjects;
+(BOOL)isUIPresent;
+(float)volumeStep;
+(void)setVolumeSteps:(short)steps;
+(void)makeChangesSilently;
-(void)presentUI;
-(void)reorientUIForOrientation:(long long)orientation withAnimationDuration:(NSTimeInterval)duration;
-(void)setIsRingerHUD:(BOOL)isRinger;
-(void)updateVolumeLevel:(float)volume;
-(UIView *)_viewFromTouchedView:(UIView *)subview atPoint:(CGPoint)point;
-(void)setRingerSilent:(BOOL)silent;
-(void)presentForMuteSwitch:(BOOL)mute;
-(void)increaseVolume;
-(void)decreaseVolume;
-(void)handleVolumeButtonWithType:(long long)type down:(BOOL)isDown;
-(void)handleHomeScreenPresence;
@end




@interface SVCWindow : UIWindow
-(instancetype)initWithDebugName:(NSString *)name;
@end




@interface UIScreen ()
-(CGRect)_referenceBounds;
-(CGFloat)_displayCornerRadius;
@end

@interface UIApplication()
-(CGFloat)statusBarHeight;
-(long long)activeInterfaceOrientation;
@end

@interface SBVolumeHUDSettings : NSObject
-(CGFloat)volumeButtonsCenterY;
@end

@interface SBElasticVolumeViewController : NSObject
-(SBVolumeHUDSettings *)settings;
@end

@interface SBVolumeControl : NSObject
-(void)setActiveCategoryVolume:(float)volume;
@end

@interface UIVibrancyEffect ()
+(UIVibrancyEffect *)effectForBlurEffect:(UIBlurEffect *)effect style:(long long)style;
@end

@interface CALayer ()
-(void)setContinuousCorners:(BOOL)continuous;
@end

@interface UIVisualEffectView ()
-(void)setAllowsBlurring:(BOOL)blur;
@end

@interface _UIStatusBarVisualProvider_Split : NSObject
+(double)notchBottomCornerRadius;
@end

@interface SBLockScreenManager : NSObject
-(BOOL)unlockUIFromSource:(int)source withOptions:(NSDictionary *)options;
-(void)lockUIFromSource:(int)source withOptions:(NSDictionary *)options;
-(BOOL)isLockScreenActive;
@end

@interface _UIViewControllerTransitionCoordinator : NSObject
-(NSTimeInterval)transitionDuration;
@end

@interface SBRingerHUDViewController : NSObject
-(float)volume;
@end

@interface UIImpactFeedbackGenerator ()
-(void)_prepareWithStyle:(long long)style;
@end

@interface SBScreenWakeAnimationController : NSObject
+(id)sharedInstance;
-(void)sleepForSource:(long long)arg1 completion:(/*^block*/id)arg2 ;
@end

@interface SBExternalSoundsDefaults : NSObject
-(void)setButtonsCanChangeRingerVolume:(BOOL)arg1 ;
@end


