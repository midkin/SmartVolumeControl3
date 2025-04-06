



// #import <stdio.h>
// #import <unistd.h>
// #import <string.h>
// #import "substrate.h"

// void mylog(const char *mytxt) {

//     const char *path = "/tmp/svc3log";
//     FILE *p = fopen(path, "a");

//     if (p) {
//         char prognametxt[50];
//         sprintf(prognametxt, "%s[%d]", getprogname(), getpid());

//         char logtxt[strlen(mytxt) + 50];
//         sprintf(logtxt,"%s %s\n", prognametxt, mytxt);
//         fwrite(logtxt, strlen(logtxt), 1, p);
//         fclose(p);
//     }
// }

// #define NSLog(...) mylog([[NSString stringWithFormat:__VA_ARGS__] UTF8String])





#import "SVCController.h"


@implementation SVCController {
	
	SVCWindow *_window;

	UIView *_rootView;
	UIView *_containerView;

	UIView *_iconView;

	UIView *_volumePanView;
	UIView *_volumeView;

	UIView *_contentView0;
	UIView *_contentContainerView0;
	UIView *_contentContainerView1;

	UIVisualEffectView *_effectView0;
	UIVisualEffectView *_effectView1;
	UIVisualEffectView *_effectView2;

	UILabel *_label0;
	UILabel *_label1;

	CAShapeLayer *_shape0;
	CAShapeLayer *_shape1;
	CAShapeLayer *_shape2;
	CAShapeLayer *_shape3;
	CAShapeLayer *_shape4;

	CAShapeLayer *_shape;

	NSString *_volumeString;
	NSString *_ringerString;
	NSString *_silentString;
	NSString *_muteString;

	BOOL _isRingerHUD;
	BOOL _isRingerSilent;
	BOOL _muteSwitchMoved;

	float _volume;

	id _haptic;

}

// Adaptive
#define UIBlurEffectStyleSystemUltraThinMaterial 6
#define UIBlurEffectStyleSystemThinMaterial 7
#define UIBlurEffectStyleSystemMaterial 8
#define UIBlurEffectStyleSystemThickMaterial 9
// Light
#define UIBlurEffectStyleSystemUltraThinMaterialLight 11
#define UIBlurEffectStyleSystemThinMaterialLight 12
#define UIBlurEffectStyleSystemMaterialLight 13
#define UIBlurEffectStyleSystemThickMaterialLight 14
// Dark
#define UIBlurEffectStyleSystemUltraThinMaterialDark 16
#define UIBlurEffectStyleSystemThinMaterialDark 17
#define UIBlurEffectStyleSystemMaterialDark 18
#define UIBlurEffectStyleSystemThickMaterialDark 19
// No Background (For OLED)
#define UIBlurEffectStyleNone -1;
// Vibrancy
#define UIVibrancyEffectStyleFill 4
#define UIVibrancyEffectStyleLabel 0


enum {

	CLASSIC,
	BIGNOTCHY,
	NOTCHY,
	PILL,
	DISC,
	MINIMAL,
	VIDEOPLAYER,
	WINDOWS10,
	ANDROID,
	TRIANGLE,
	BOTTOMBAR

};

enum {

	VERYTHIN,
	THIN,
	REGULAR,
	THICK

};

enum {

	ADAPTIVE,
	LIGHT,
	DARK,
	OLED

};


static SVCController *sharedController = nil;
static short volumeSteps = -1;

static unsigned char viewStyle = 0;

static BOOL viewStyleUsesIcons = NO;
static unsigned char viewStyleLabelCount = 0;
static BOOL viewStyleIncludesThemes = NO;
static BOOL isRingerIcon = NO;
static BOOL previousIsRingerHUD = NO;

static CGRect referenceBounds;
static CGFloat screenScale = 0.0;
static CGFloat sbHeight = 0.0;
static CGRect notchFrame;
static CGFloat volumeButtonsCenterY = 0.0;
static BOOL isNotchDevice = NO;

static unsigned short backgroundType = 0;
static unsigned short backgroundThickness = 2;

static BOOL moreSpeakerOpacitySteps = NO;
static BOOL maxVolumeAnimation = NO;
static double firstPressVisibility = 1.0;
static NSTimeInterval autoDismissDelay = 2.0;
static NSTimeInterval firstPressDismissDelay = 2.0;

static BOOL hapticFeedback = NO;
static BOOL minHapticFeedback = NO;
static BOOL maxHapticFeedback = NO;
static BOOL allHapticFeedback = NO;
static unsigned char minHapticFeedbackIntensity = 0;
static unsigned char maxHapticFeedbackIntensity = 0;
static unsigned char otherHapticFeedbackIntensity = 0;

static BOOL lockscreenVolume = NO;
static BOOL wakeScreen = NO;
static BOOL didWakeScreen = NO;
static BOOL oledLockScreenVolume = NO;

static BOOL performedEdgeHaptic = NO;
static BOOL makeChangesSilently = NO;

static BOOL touchHaptic = NO;
static BOOL isPanning = NO;




+(instancetype)sharedInstance {

	if (!sharedController)
		sharedController = [[self alloc] init];

	return sharedController;

}

+(BOOL)isUIPresent {

	return sharedController != nil ? YES : NO;

}

+(void)setVolumeSteps:(short)steps {

	volumeSteps = steps;

}

+(float)volumeStep {

	if (volumeSteps < 0) {
		NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
		volumeSteps = [defaults objectForKey:@"volumeSteps"] ? [[defaults objectForKey:@"volumeSteps"] intValue] : 16;
		[defaults release];
	}	

	return (float)1.0 / (float)volumeSteps;

}

+(void)makeChangesSilently {

	makeChangesSilently = YES;

}

-(instancetype)init {

	self = [super init];
	if (self && [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {

		NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
		viewStyle = [defaults objectForKey:@"viewStyle"] ? [[defaults objectForKey:@"viewStyle"] unsignedCharValue] : 0;
		[self _readViewStyleSettings];
		if (viewStyleIncludesThemes) {
			backgroundType = [defaults objectForKey:@"backgroundType"] ? [[defaults objectForKey:@"backgroundType"] unsignedCharValue] : 0;
			backgroundThickness = [defaults objectForKey:@"backgroundThickness"] ? [[defaults objectForKey:@"backgroundThickness"] unsignedCharValue] : 2;
		}
		if (viewStyleUsesIcons && viewStyle != ANDROID)
			moreSpeakerOpacitySteps = [defaults objectForKey:@"moreSpeakerOpacitySteps"] ? [[defaults objectForKey:@"moreSpeakerOpacitySteps"] boolValue] : NO;
		maxVolumeAnimation = [defaults objectForKey:@"maxVolumeAnimation"] ? [[defaults objectForKey:@"maxVolumeAnimation"] boolValue] : NO;
		firstPressVisibility = [defaults objectForKey:@"firstPressVisibility"] ? [[defaults objectForKey:@"firstPressVisibility"] doubleValue] : 1.0;
		if ([[defaults objectForKey:@"autoDismissDelay"] respondsToSelector:@selector(doubleValue)])
			autoDismissDelay = [defaults objectForKey:@"autoDismissDelay"] ? [[defaults objectForKey:@"autoDismissDelay"] doubleValue] : 2.0;
		else if ([[defaults objectForKey:@"autoDismissDelay"] respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)]) {
			NSString *autoDismissDelayString = [[NSString alloc] initWithString:[[defaults objectForKey:@"autoDismissDelay"] stringByReplacingOccurrencesOfString:@"," withString:@"."]];
			autoDismissDelay = autoDismissDelayString != nil ? [autoDismissDelayString doubleValue] : 2.0;
			[autoDismissDelayString release];
		}
		firstPressDismissDelay = [defaults objectForKey:@"firstPressDismissDelay"] ? [[defaults objectForKey:@"firstPressDismissDelay"] doubleValue] : 1.0;

		hapticFeedback = [defaults objectForKey:@"hapticFeedback"] ? [[defaults objectForKey:@"hapticFeedback"] boolValue] : NO;
		minHapticFeedback = [defaults objectForKey:@"minHapticFeedback"] ? [[defaults objectForKey:@"minHapticFeedback"] boolValue] : NO;
		maxHapticFeedback = [defaults objectForKey:@"maxHapticFeedback"] ? [[defaults objectForKey:@"maxHapticFeedback"] boolValue] : NO;
		allHapticFeedback = [defaults objectForKey:@"allHapticFeedback"] ? [[defaults objectForKey:@"allHapticFeedback"] boolValue] : NO;
		minHapticFeedbackIntensity = [defaults objectForKey:@"minHapticFeedbackIntensity"] ? [[defaults objectForKey:@"minHapticFeedbackIntensity"] unsignedCharValue] : 0;
		maxHapticFeedbackIntensity = [defaults objectForKey:@"maxHapticFeedbackIntensity"] ? [[defaults objectForKey:@"maxHapticFeedbackIntensity"] unsignedCharValue] : 0;
		otherHapticFeedbackIntensity = [defaults objectForKey:@"otherHapticFeedbackIntensity"] ? [[defaults objectForKey:@"otherHapticFeedbackIntensity"] unsignedCharValue] : 0;
		touchHaptic = [defaults objectForKey:@"touchHaptic"] ? [[defaults objectForKey:@"touchHaptic"] boolValue] : NO;
		lockscreenVolume = [defaults objectForKey:@"lockscreenVolume"] ? [[defaults objectForKey:@"lockscreenVolume"] boolValue] : NO;
		wakeScreen = [defaults objectForKey:@"wakeScreen"] ? [[defaults objectForKey:@"wakeScreen"] boolValue] : NO;
		oledLockScreenVolume = [defaults objectForKey:@"oledLockScreenVolume"] ? [[defaults objectForKey:@"oledLockScreenVolume"] boolValue] : NO;
		[defaults synchronize];
		[defaults release];

		[[objc_getClass("AVSystemController") sharedAVSystemController] getActiveCategoryVolume:&_volume andName:nil];

		referenceBounds = [[UIScreen mainScreen] _referenceBounds];
		screenScale = [[UIScreen mainScreen] scale];
		sbHeight = [[UIApplication sharedApplication] statusBarHeight];

		if ([[UIApplication sharedApplication] respondsToSelector:@selector(statusBar)] && [[[UIApplication sharedApplication] performSelector:@selector(statusBar)] respondsToSelector:@selector(statusBar)] && [[[[UIApplication sharedApplication] performSelector:@selector(statusBar)] performSelector:@selector(statusBar)] respondsToSelector:@selector(visualProvider)] && [[[[[UIApplication sharedApplication] performSelector:@selector(statusBar)] performSelector:@selector(statusBar)] performSelector:@selector(visualProvider)] respondsToSelector:@selector(cutoutLayoutGuide)])
			notchFrame = [(UILayoutGuide *)[[[[[UIApplication sharedApplication] performSelector:@selector(statusBar)] performSelector:@selector(statusBar)] performSelector:@selector(visualProvider)] performSelector:@selector(cutoutLayoutGuide)] layoutFrame];
		else {
			if (referenceBounds.size.width > 428.0)
				notchFrame = CGRectMake(0.24718196 * 428.0, 0.0, 0.50563607 * 428.0, 30.0);
			else
				notchFrame = CGRectMake(0.24718196 * referenceBounds.size.width, 0.0, 0.50563607 * referenceBounds.size.width, 30.0);
		}

		isNotchDevice = [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] && ![UIDevice _hasHomeButton] ? YES : NO;

		if (viewStyle == WINDOWS10) {
			SBElasticVolumeViewController *ctrl = [[objc_getClass("SBElasticVolumeViewController") alloc] init];
			volumeButtonsCenterY = [[ctrl settings] volumeButtonsCenterY];
			[ctrl release];
		}

		return self;

	}

	return nil;

}

-(void)releaseObjects {

	if (!_window)
		return;

	_muteSwitchMoved = NO;
	performedEdgeHaptic = NO;

	if (_haptic != nil)
		[_haptic release];

	if (viewStyle == DISC || viewStyle == TRIANGLE)
		[_shape release];

	if (viewStyleUsesIcons) {
		if (!isRingerIcon) {
			if (viewStyle != ANDROID) {
				[_shape4 release];
				[_shape3 release];
			}
		}
		else {
			[_shape2 release];
			[_shape1 release];
		}
		[_shape0 release];
		_shape0 = nil;
		[_iconView release];
	}

	if (viewStyleLabelCount) {
		[_silentString release];
		[_muteString release];
		[_label0 release];
		if (viewStyleLabelCount == 2) {
			[_volumeString release];
			[_ringerString release];
			[_label1 release];
		}
	}

	if (viewStyle != DISC) {
		[_volumeView release];
		[_volumePanView release];
		if (viewStyle == VIDEOPLAYER || viewStyle == WINDOWS10 || viewStyle == ANDROID) {
			if (viewStyle == ANDROID) {
				[_contentContainerView1 release];
			}
			[_contentContainerView0 release];
			[_contentView0 release];
		}
	}

	[_effectView2 release];
	[_effectView1 release];
	[_effectView0 release];
	[_containerView release];
	[_rootView release];

	[_window release];
	_window = nil;

	[sharedController release];
	sharedController = nil;

}

-(void)setIsRingerHUD:(BOOL)isRinger {

	static dispatch_once_t once;
	dispatch_once(&once, ^ { previousIsRingerHUD = !isRinger; });

	_isRingerHUD = isRinger;

}

-(void)presentForMuteSwitch:(BOOL)mute {

    _muteSwitchMoved = mute;

}

-(void)setRingerSilent:(BOOL)silent {

    _isRingerSilent = silent;

}

-(void)updateVolumeLevel:(float)volume {

	_volume = volume;
	[self _prepareHaptic];

}

-(void)_prepareHaptic {

	// UINotificationFeedbackGenerator 1 -> Success
	// UINotificationFeedbackGenerator 0 -> Error
	// UISelectionFeedbackGenerator even softer
	// UIImpactFeedbackStyleSoft ??? 3
	// UIImpactFeedbackStyleLight 0
	// UIImpactFeedbackStyleMedium 1
	// UIImpactFeedbackStyleRigid ??? 4 Like Medium less duration
	// UIImpactFeedbackStyleHeavy 2

	if (!hapticFeedback || [[UIDevice currentDevice] _feedbackSupportLevel] < 2 || (!touchHaptic && isPanning))
		return;
		
	NSString *category = nil;
	[[objc_getClass("AVSystemController") sharedAVSystemController] getActiveCategoryVolume:nil andName:&category];

	float min = 0.0;
	if (![category isEqualToString:@"Audio/Video"])
		min = 0.0625;

	if (_volume == min && minHapticFeedback) {
		// Minimum volume level and haptic feedback enabled for minimum volume level.
		[_haptic release];
		if (minHapticFeedbackIntensity == 5)
			_haptic = [[UISelectionFeedbackGenerator alloc] init];
		else if (minHapticFeedbackIntensity <= 4)
			_haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:(minHapticFeedbackIntensity)];
		else if (minHapticFeedbackIntensity > 5 )
			_haptic = [[UINotificationFeedbackGenerator alloc] init];
	}
	else if (_volume != min && _volume != 1.0 && allHapticFeedback) {
		// NOT minimum AND NOT maximum volume level and haptic feedback enabled for for that.
		[_haptic release];
		if (otherHapticFeedbackIntensity == 5)
			_haptic = [[UISelectionFeedbackGenerator alloc] init];
		else if (otherHapticFeedbackIntensity <= 4)
			_haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:(otherHapticFeedbackIntensity)];
		else if (otherHapticFeedbackIntensity > 5)
			_haptic = [[UINotificationFeedbackGenerator alloc] init];
	}
	else if (_volume == 1.0 && maxHapticFeedback) {
		[_haptic release];
		// Maximum volume level and haptic feedback enabled for maximum volume level.
		if (maxHapticFeedbackIntensity == 5)
			_haptic = [[UISelectionFeedbackGenerator alloc] init];
		else if (maxHapticFeedbackIntensity <= 4) 
			_haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:(maxHapticFeedbackIntensity)];
		else if (maxHapticFeedbackIntensity > 5)
			_haptic = [[UINotificationFeedbackGenerator alloc] init];
	}

	[_haptic prepare];

}

-(void)_performHaptic {

	unsigned char supportLevel = [[UIDevice currentDevice] _feedbackSupportLevel];

	if (!hapticFeedback || !supportLevel || (!touchHaptic && isPanning))
		return;
		
	NSString *category = nil;
	[[objc_getClass("AVSystemController") sharedAVSystemController] getActiveCategoryVolume:nil andName:&category];

	float min = 0.0;
	if (![category isEqualToString:@"Audio/Video"])
		min = 0.0625;

	if (performedEdgeHaptic && (_volume == 1 || _volume == min))
		return;

	if (_volume == 1.0 || _volume == min)
		performedEdgeHaptic = YES;
	else
		performedEdgeHaptic = NO;

	if (supportLevel == 1) {

		if (minHapticFeedback && _volume == min) {
			if (!minHapticFeedbackIntensity)
				AudioServicesPlaySystemSound(1519);
			else
				AudioServicesPlaySystemSound(1520);
		}
		else if (maxHapticFeedback && _volume == 1.0) {
			if (!maxHapticFeedbackIntensity)
				AudioServicesPlaySystemSound(1519);
			else
				AudioServicesPlaySystemSound(1520);
		}
		else if (allHapticFeedback && _volume != min && _volume != 1.0) {
			if (!otherHapticFeedbackIntensity)
				AudioServicesPlaySystemSound(1519);
			else
				AudioServicesPlaySystemSound(1520);
		}

	}

	else if (supportLevel == 2) {

		if ((_volume == min && !minHapticFeedback) || (_volume == 1.0 && !maxHapticFeedback) || (_volume != min && _volume != 1.0 && !allHapticFeedback))
			return;

		if ([_haptic isMemberOfClass:[UISelectionFeedbackGenerator class]])
			[_haptic selectionChanged];
		else if ([_haptic isMemberOfClass:[UIImpactFeedbackGenerator class]])
			[_haptic impactOccurred];
		else if ([_haptic isMemberOfClass:[UINotificationFeedbackGenerator class]]) {
			if (_volume == min)
				[_haptic notificationOccurred:minHapticFeedbackIntensity - 5];
			else if (_volume != min && _volume != 1.0)
				[_haptic notificationOccurred:otherHapticFeedbackIntensity - 5];
			else if (_volume == 1.0)
				[_haptic notificationOccurred:maxHapticFeedbackIntensity - 5];
		}

	}

}

-(UIBlurEffectStyle)_backgroundEffect {

	if (!viewStyleIncludesThemes) {
		if (viewStyle == WINDOWS10)
			return UIBlurEffectStyleSystemThickMaterialDark;
		else if (viewStyle == ANDROID)
			return UIBlurEffectStyleSystemThickMaterialLight;
		else if (viewStyle == TRIANGLE)
			return UIBlurEffectStyleNone;
	
		return UIBlurEffectStyleSystemMaterialDark;
	}

    if (backgroundType == ADAPTIVE) {
        if (backgroundThickness == VERYTHIN)
            return UIBlurEffectStyleSystemUltraThinMaterial;
        else if (backgroundThickness == THIN)
            return UIBlurEffectStyleSystemThinMaterial;
        else if (backgroundThickness == REGULAR)
            return UIBlurEffectStyleSystemMaterial;
        else if (backgroundThickness == THICK)
            return UIBlurEffectStyleSystemThickMaterial;
    }
    else if (backgroundType == LIGHT) {
        if (backgroundThickness == VERYTHIN)
            return UIBlurEffectStyleSystemUltraThinMaterialLight;
        else if (backgroundThickness == THIN)
            return UIBlurEffectStyleSystemThinMaterialLight;
        else if (backgroundThickness == REGULAR)
            return UIBlurEffectStyleSystemMaterialLight;
        else if (backgroundThickness == THICK)
            return UIBlurEffectStyleSystemThickMaterialLight;
    }
    else if (backgroundType == DARK) {
        if (backgroundThickness == VERYTHIN)
            return UIBlurEffectStyleSystemUltraThinMaterialDark;
        else if (backgroundThickness == THIN)
            return UIBlurEffectStyleSystemThinMaterialDark;
        else if (backgroundThickness == REGULAR)
            return UIBlurEffectStyleSystemMaterialDark;
        else if (backgroundThickness == THICK)
            return UIBlurEffectStyleSystemThickMaterialDark;
    }

    return UIBlurEffectStyleNone;

}

-(void)increaseVolume {

	if (!_window)
		return;

	if (viewStyle == VIDEOPLAYER && _contentView0.transform.a <= 1.0)
		[UIView animateWithDuration:0.1
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _contentView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15, 1.15); }
		completion:^ (BOOL finished) {}];

	if (maxVolumeAnimation && _volume == 1.0) {
		if (viewStyle == CLASSIC || viewStyle == BIGNOTCHY || viewStyle == NOTCHY || viewStyle == BOTTOMBAR)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{ _volumePanView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 0.8); }
			completion:^ (BOOL finished) {}];
		else if (viewStyle == PILL || viewStyle == MINIMAL || viewStyle == TRIANGLE)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				if (viewStyle == MINIMAL) {
					long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
					_window.transform = CGAffineTransformConcat([self _windowTransformForOrientation:orientation], CGAffineTransformScale(CGAffineTransformIdentity, orientation == 1 || orientation == 2 ? 1.1 : 1.0, orientation == 1 || orientation == 2 ? 1.0 : 1.1));
				}
				else
					_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.075, 0.925);
			}
			completion:^ (BOOL finished) {}];
		else if (viewStyle == DISC)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{ _shape.transform = CATransform3DScale(CATransform3DIdentity, 1.025, 1.025, 1.0); }
			completion:^ (BOOL finished) {}];
		else if (viewStyle == VIDEOPLAYER)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				_contentContainerView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 0.75);
				_contentView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0925, 1.4375);
			}
			completion:^ (BOOL finished) {}];
		else if (viewStyle == WINDOWS10 || viewStyle == ANDROID)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				_contentContainerView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 1.0375);
				if (viewStyle == ANDROID)
					_contentContainerView1.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
			}
			completion:^ (BOOL finished) {}];
	}

}

-(void)decreaseVolume {

	if (!_window)
		return;

	if (viewStyle == VIDEOPLAYER && (_contentView0.transform.a >= 1.0 || !_contentView0.transform.a))
		[UIView animateWithDuration:0.1
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _contentView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85); }
		completion:^ (BOOL finished) {}];

}

-(void)handleVolumeButtonWithType:(long long)type down:(BOOL)isDown {

	if (isDown) {
		makeChangesSilently = NO;
		performedEdgeHaptic = NO;
	}

	if (!_window)
		return;

	if (viewStyle == VIDEOPLAYER && !isDown && _contentView0.transform.a && _contentView0.transform.a != 1.0 && _volume != 0.0)
		[UIView animateWithDuration:0.1
		delay:0.1
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _contentView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
		completion:^ (BOOL finished) {}];

	if (maxVolumeAnimation && _volume == 1.0 && !isDown) {
		if (viewStyle == CLASSIC || viewStyle == BIGNOTCHY || viewStyle == NOTCHY || viewStyle == BOTTOMBAR)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{ _volumePanView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
			completion:^ (BOOL finished) {}];
		else if (viewStyle == PILL || viewStyle == MINIMAL || viewStyle == TRIANGLE)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				if (viewStyle == MINIMAL) {
					long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
					_window.transform = CGAffineTransformConcat([self _windowTransformForOrientation:orientation], CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0));
				}
				else
					_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
			}
			completion:^ (BOOL finished) {}];
		else if (viewStyle == DISC)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{ _shape.transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0); }
			completion:^ (BOOL finished) {}];
		else if (viewStyle == VIDEOPLAYER)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				_contentContainerView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
				if (_volume == 1.0)
					_contentView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
			}
			completion:^ (BOOL finished) {}];
		else if (viewStyle == WINDOWS10 || viewStyle == ANDROID)
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				_contentContainerView0.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
				if (viewStyle == ANDROID)
					_contentContainerView1.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
			}
			completion:^ (BOOL finished) {}];
	}

}

-(UIView *)_viewFromTouchedView:(UIView *)subview atPoint:(CGPoint)point {

	if (_window.backgroundColor == [UIColor blackColor]) {
		didWakeScreen = NO;
		[UIView animateWithDuration:0.45
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _window.backgroundColor = [UIColor clearColor]; }
		completion:^ (BOOL finished) {}];
	}

	if (point.x >= _containerView.frame.origin.x && point.x <= (_containerView.frame.origin.x + _containerView.frame.size.width) && point.y >= _containerView.frame.origin.y + _volumePanView.frame.origin.y - 15.0 && point.y <= _containerView.frame.origin.y + _containerView.frame.size.height)
		return _volumePanView;

	return nil;

}

-(void)_readViewStyleSettings {

	if (viewStyle == CLASSIC) {
		viewStyleUsesIcons = YES;
		viewStyleLabelCount = 2;
		viewStyleIncludesThemes = YES;
	}
	else if (viewStyle == BIGNOTCHY) {
		viewStyleUsesIcons = NO;
		viewStyleLabelCount = 2;
		viewStyleIncludesThemes = YES;
	}
	else if (viewStyle == NOTCHY || viewStyle == VIDEOPLAYER || viewStyle == BOTTOMBAR) {
		viewStyleUsesIcons = YES;
		viewStyleLabelCount = 1;
		viewStyleIncludesThemes = YES;
	}
	else if (viewStyle == PILL) {
		viewStyleUsesIcons = YES;
		viewStyleLabelCount = 0;
		viewStyleIncludesThemes = NO;
	}
	else if (viewStyle == DISC) {
		viewStyleUsesIcons = YES;
		viewStyleLabelCount = 0;
		viewStyleIncludesThemes = YES;
	}
	else if (viewStyle == MINIMAL) {
		viewStyleUsesIcons = NO;
		viewStyleLabelCount = 1;
		viewStyleIncludesThemes = NO;
	}
	else if (viewStyle == WINDOWS10) {
		viewStyleUsesIcons = NO;
		viewStyleLabelCount = 1;
		viewStyleIncludesThemes = YES;
	}
	else if (viewStyle == ANDROID) {
		viewStyleUsesIcons = YES;
		viewStyleLabelCount = 2;
		viewStyleIncludesThemes = NO;
	}
	else if (viewStyle == TRIANGLE) {
		viewStyleUsesIcons = NO;
		viewStyleLabelCount = 0;
		viewStyleIncludesThemes = NO;
	}

}

-(void)_volumeViewPanned:(UIPanGestureRecognizer *)recognizer {

	static short previousStep = 0;
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		isPanning = YES;
		previousStep = volumeSteps;
		volumeSteps = 10000;
	}
	else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
			isPanning = NO;
		});
		volumeSteps = previousStep;
	}

	if (viewStyle == BOTTOMBAR) {
		if (recognizer.state == UIGestureRecognizerStateBegan) {
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				_volumePanView.frame = CGRectMake(65.0, 20.0, _containerView.frame.size.width - 150.0, 20.0);
				_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;
			}
			completion:^ (BOOL finished) {}];
		}
		else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
			[UIView animateWithDuration:0.3
			delay:0.0
			options:UIViewAnimationOptionAllowUserInteraction
			animations:^{
				_volumePanView.frame = CGRectMake(65.0, 28.0, _containerView.frame.size.width - 150.0, 4.0);
				_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;
			}
			completion:^ (BOOL finished) {}];
		}
	}

	CGPoint center = [recognizer locationInView:_volumePanView];
	CGFloat x = center.x;
	CGFloat y = center.y;

	if (viewStyle == WINDOWS10 || viewStyle == ANDROID)
		[[objc_getClass("SBVolumeControl") sharedInstance] setActiveCategoryVolume:1.0 - y / _volumePanView.frame.size.height];
	else
		[[objc_getClass("SBVolumeControl") sharedInstance] setActiveCategoryVolume:x / _volumePanView.frame.size.width];
    
}

-(void)_basicAnimationFor:(CALayer *)layer withKeyPath:(NSString *)keyPath andDuration:(NSTimeInterval)duration beginIn:(CFTimeInterval)sec toValue:(CGFloat)value isDismissal:(BOOL)dismissal {

	CABasicAnimation *animation = [[CABasicAnimation alloc] init];
	[animation setKeyPath:keyPath];
	animation.duration = duration;
	animation.beginTime = CACurrentMediaTime() + sec;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.toValue = [NSNumber numberWithDouble:value];
	if (dismissal)
		animation.delegate = (id<CAAnimationDelegate>)self;
	else
		animation.fromValue = [NSNumber numberWithDouble:0.0];
	[layer addAnimation:animation forKey:keyPath];
	[animation release];

}

-(void)_createSpeakerIcon {

	if (!_shape0) {

		_shape0 = [[CAShapeLayer alloc] init];
		_shape0.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);

		UIBezierPath* path = [[UIBezierPath alloc] init];
		[path moveToPoint:CGPointMake(19.6, 64.41)];
		[path addLineToPoint:CGPointMake(40.11, 84.34)];
		[path addLineToPoint:CGPointMake(40.11, 84.34)];
		[path addCurveToPoint:CGPointMake(42.94, 84.29) controlPoint1:CGPointMake(40.91, 85.11) controlPoint2:CGPointMake(42.17, 85.09)];
		[path addCurveToPoint:CGPointMake(43.5, 82.9) controlPoint1:CGPointMake(43.3, 83.92) controlPoint2:CGPointMake(43.5, 83.42)];
		[path addLineToPoint:CGPointMake(43.5, 18.5)];
		[path addLineToPoint:CGPointMake(43.5, 18.51)];
		[path addCurveToPoint:CGPointMake(41.5, 16.51) controlPoint1:CGPointMake(43.5, 17.4) controlPoint2:CGPointMake(42.6, 16.51)];
		[path addCurveToPoint:CGPointMake(40.11, 17.07) controlPoint1:CGPointMake(40.98, 16.51) controlPoint2:CGPointMake(40.48, 16.71)];
		[path addLineToPoint:CGPointMake(19.6, 37)];
		[path addLineToPoint:CGPointMake(19.6, 37)];
		[path addCurveToPoint:CGPointMake(17.87, 37.7) controlPoint1:CGPointMake(19.13, 37.45) controlPoint2:CGPointMake(18.51, 37.7)];
		[path addLineToPoint:CGPointMake(10.5, 37.7)];
		[path addLineToPoint:CGPointMake(10.5, 37.7)];
		[path addCurveToPoint:CGPointMake(5.5, 42.7) controlPoint1:CGPointMake(7.74, 37.7) controlPoint2:CGPointMake(5.5, 39.94)];
		[path addLineToPoint:CGPointMake(5.5, 58.7)];
		[path addLineToPoint:CGPointMake(5.5, 58.7)];
		[path addCurveToPoint:CGPointMake(10.5, 63.7) controlPoint1:CGPointMake(5.5, 61.46) controlPoint2:CGPointMake(7.74, 63.7)];
		[path addLineToPoint:CGPointMake(17.86, 63.7)];
		[path addLineToPoint:CGPointMake(17.85, 63.7)];
		[path addCurveToPoint:CGPointMake(19.59, 64.4) controlPoint1:CGPointMake(18.5, 63.7) controlPoint2:CGPointMake(19.13, 63.95)];
		[path addLineToPoint:CGPointMake(19.6, 64.41)];
		[path closePath];

		_shape0.path = path.CGPath;
		[path release];
		_shape0.fillColor = [UIColor whiteColor].CGColor;
		_shape0.lineCap = kCALineCapRound;
		_shape0.lineJoin = kCALineJoinRound;
		_shape0.lineWidth = 1.0;
		_shape0.contentsScale = screenScale;

		_shape1 = [[CAShapeLayer alloc] init];
		_shape1.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		path = [[UIBezierPath alloc] init];

		[path moveToPoint:CGPointMake(55.0, 40.0)];
		[path addQuadCurveToPoint:CGPointMake(55.0, 60.0) controlPoint:CGPointMake(65.0, 50.0)];

		_shape1.path = path.CGPath;
		[path release];
		_shape1.strokeColor = [[UIColor whiteColor] CGColor];
		_shape1.fillColor = [[UIColor clearColor] CGColor];
		if (viewStyle != CLASSIC)
			_shape1.lineWidth = 5.0;
		else
			_shape1.lineWidth = 3.0;
		_shape1.lineCap = kCALineCapRound;
		_shape1.contentsScale = screenScale;

		_shape2 = [[CAShapeLayer alloc] init];
		_shape2.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		path = [[UIBezierPath alloc] init];

		[path moveToPoint:CGPointMake(67.5, 30.0)];
		[path addQuadCurveToPoint:CGPointMake(67.5, 70.0) controlPoint:CGPointMake(85.0, 50.0)];

		_shape2.path = path.CGPath;
		[path release];
		_shape2.strokeColor = [[UIColor whiteColor] CGColor];
		_shape2.fillColor = [[UIColor clearColor] CGColor];
		if (viewStyle != CLASSIC)
			_shape2.lineWidth = 5.25;
		else
			_shape2.lineWidth = 3.25;
		_shape2.lineCap = kCALineCapRound;
		_shape2.contentsScale = screenScale;

		_shape3 = [[CAShapeLayer alloc] init];
		_shape3.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		path = [[UIBezierPath alloc] init];

		[path moveToPoint:CGPointMake(82.5, 20.0)];
		[path addQuadCurveToPoint:CGPointMake(82.5, 80.0) controlPoint:CGPointMake(105.0, 50.0)];

		_shape3.path = path.CGPath;
		[path release];
		_shape3.strokeColor = [[UIColor whiteColor] CGColor];
		_shape3.fillColor = [[UIColor clearColor] CGColor];
		if (viewStyle != CLASSIC)
			_shape3.lineWidth = 5.5;
		else
			_shape3.lineWidth = 3.5;
		
		_shape3.lineCap = kCALineCapRound;
		_shape3.contentsScale = screenScale;

		_shape4 = [[CAShapeLayer alloc] init];
		_shape4.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		path = [[UIBezierPath alloc] init];

		[path moveToPoint:CGPointMake(55.04, 35.41)];
		[path addLineToPoint:CGPointMake(84.18, 64.55)];
		[path moveToPoint:CGPointMake(84.96, 35.41)];
		[path addLineToPoint:CGPointMake(72.7, 47.64)];
		[path moveToPoint:CGPointMake(67.3, 53.04)];
		[path addLineToPoint:CGPointMake(55.38, 65)];

		_shape4.path = path.CGPath;
		[path release];
		_shape4.strokeColor = [[UIColor whiteColor] CGColor];
		_shape4.fillColor = [[UIColor clearColor] CGColor];
		if (viewStyle != CLASSIC)
			_shape4.lineWidth = 6.0;
		else
			_shape4.lineWidth = 4.0;
		_shape4.contentsScale = screenScale;

		[_shape0 addSublayer:_shape1];
		[_shape0 addSublayer:_shape2];
		[_shape0 addSublayer:_shape3];
		[_shape0 addSublayer:_shape4];

		[_iconView.layer addSublayer:_shape0];

		if (viewStyle != CLASSIC)
			_iconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.225, 0.225);
		else
			_iconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);

		isRingerIcon = NO;

	}

}

-(void)_speakerIconUpdate {

	static BOOL hasPlayedMuteAnimation = NO;

	if (!_volume) {
		_shape1.opacity = 0.0;
		_shape2.opacity = 0.0;
		_shape3.opacity = 0.0;
		_shape4.opacity = 1.0;

		if (!hasPlayedMuteAnimation) {
			[self _basicAnimationFor:_shape4 withKeyPath:@"strokeEnd" andDuration:0.5 beginIn:0 toValue:1.0 isDismissal:NO];
			hasPlayedMuteAnimation = YES;
		}
	}
	else {
		if (!_isRingerHUD)
			hasPlayedMuteAnimation = NO;
		_shape4.opacity = 0.0;
		if (!moreSpeakerOpacitySteps) {
			if (_volume >= 0.66) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 1.0;
				_shape3.opacity = 1.0;
			}
			else if (_volume >= 0.33) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 1.0;
				_shape3.opacity = 0.0;
			}
			else {
				_shape1.opacity = 1.0;
				_shape2.opacity = 0.0;
				_shape3.opacity = 0.0;
			}
		}
		else {
			if (_volume >= 0.88) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 1.0;
				_shape3.opacity = 1.0;
			}
			else if (_volume >= 0.77) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 1.0;
				_shape3.opacity = 0.66;
			}
			else if (_volume >= 0.66) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 1.0;
				_shape3.opacity = 0.33;
			}
			else if (_volume >= 0.55) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 1.0;
				_shape3.opacity = 0.0;
			}
			else if (_volume >= 0.44) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 0.66;
				_shape3.opacity = 0.0;
			}
			else if (_volume >= 0.33) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 0.33;
				_shape3.opacity = 0.0;
			}
			else if (_volume >= 0.22) {
				_shape1.opacity = 1.0;
				_shape2.opacity = 0.0;
				_shape3.opacity = 0.0;
			}
			else if (_volume >= 0.11) {
				_shape1.opacity = 0.66;
				_shape2.opacity = 0.0;
				_shape3.opacity = 0.0;
			}
			else {
				_shape1.opacity = 0.33;
				_shape2.opacity = 0.0;
				_shape3.opacity = 0.0;
			}
		}
	}

}

-(void)_createBellIcon {

	if (!_shape0) {

		_shape0 = [[CAShapeLayer alloc] init];
		_shape0.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
		_shape0.anchorPoint = CGPointMake(0.5, 0.0);

		UIBezierPath* path = [[UIBezierPath alloc] init];
		[path moveToPoint:CGPointMake(81.62, 64.69)];
		[path addLineToPoint:CGPointMake(81.67, 64.72)];
		[path addCurveToPoint:CGPointMake(77.52, 60.42) controlPoint1:CGPointMake(79.89, 63.73) controlPoint2:CGPointMake(78.44, 62.23)];
		[path addCurveToPoint:CGPointMake(72.25, 34.19) controlPoint1:CGPointMake(75.32, 56) controlPoint2:CGPointMake(72.25, 47.37)];
		[path addLineToPoint:CGPointMake(72.25, 34.3)];
		[path addCurveToPoint:CGPointMake(56.23, 12.65) controlPoint1:CGPointMake(72.25, 24.35) controlPoint2:CGPointMake(65.75, 15.56)];
		[path addLineToPoint:CGPointMake(56.25, 12.64)];
		[path addCurveToPoint:CGPointMake(49.76, 7) controlPoint1:CGPointMake(55.79, 9.4) controlPoint2:CGPointMake(53.03, 7)];
		[path addLineToPoint:CGPointMake(49.75, 7)];
		[path addLineToPoint:CGPointMake(49.75, 7)];
		[path addCurveToPoint:CGPointMake(43.25, 12.65) controlPoint1:CGPointMake(46.48, 7) controlPoint2:CGPointMake(43.71, 9.41)];
		[path addLineToPoint:CGPointMake(43.27, 12.65)];
		[path addCurveToPoint:CGPointMake(27.25, 34.3) controlPoint1:CGPointMake(33.75, 15.56) controlPoint2:CGPointMake(27.25, 24.35)];
		[path addCurveToPoint:CGPointMake(22, 60.44) controlPoint1:CGPointMake(27.25, 47.37) controlPoint2:CGPointMake(24.19, 56)];
		[path addLineToPoint:CGPointMake(22.03, 60.39)];
		[path addCurveToPoint:CGPointMake(18, 64.63) controlPoint1:CGPointMake(21.12, 62.16) controlPoint2:CGPointMake(19.72, 63.64)];
		[path addLineToPoint:CGPointMake(17.89, 64.7)];
		[path addCurveToPoint:CGPointMake(16.56, 70.03) controlPoint1:CGPointMake(16.05, 65.8) controlPoint2:CGPointMake(15.45, 68.19)];
		[path addLineToPoint:CGPointMake(16.53, 69.98)];
		[path addCurveToPoint:CGPointMake(16.82, 70.4) controlPoint1:CGPointMake(16.62, 70.13) controlPoint2:CGPointMake(16.71, 70.27)];
		[path addLineToPoint:CGPointMake(16.86, 70.46)];
		[path addCurveToPoint:CGPointMake(21.22, 72.63) controlPoint1:CGPointMake(17.87, 71.85) controlPoint2:CGPointMake(19.5, 72.66)];
		[path addLineToPoint:CGPointMake(78.32, 72.63)];
		[path addLineToPoint:CGPointMake(78.33, 72.63)];
		[path addCurveToPoint:CGPointMake(82.66, 70.47) controlPoint1:CGPointMake(80.04, 72.66) controlPoint2:CGPointMake(81.65, 71.85)];
		[path addLineToPoint:CGPointMake(82.69, 70.43)];
		[path addCurveToPoint:CGPointMake(82.07, 65.01) controlPoint1:CGPointMake(84, 68.76) controlPoint2:CGPointMake(83.72, 66.35)];
		[path addLineToPoint:CGPointMake(82.07, 65.01)];
		[path addCurveToPoint:CGPointMake(81.65, 64.71) controlPoint1:CGPointMake(81.94, 64.9) controlPoint2:CGPointMake(81.8, 64.8)];
		[path addLineToPoint:CGPointMake(81.62, 64.69)];
		[path closePath];

		_shape0.path = path.CGPath;
		[path release];
		_shape0.strokeColor = [UIColor whiteColor].CGColor;
		if (viewStyle != CLASSIC)
			_shape0.fillColor = [UIColor whiteColor].CGColor;
		else
			_shape0.fillColor = [UIColor clearColor].CGColor;
		_shape0.lineCap = kCALineCapRound;
		_shape0.lineJoin = kCALineJoinRound;
		_shape0.lineWidth = 3.0;
		_shape0.contentsScale = screenScale;


		_shape1 = [[CAShapeLayer alloc] init];
		_shape1.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);

		path = [[UIBezierPath alloc] init];
		[path moveToPoint:CGPointMake(56.31, 77.48)];
		[path addLineToPoint:CGPointMake(56.31, 77.48)];
		[path addCurveToPoint:CGPointMake(49.75, 84.04) controlPoint1:CGPointMake(56.31, 81.1) controlPoint2:CGPointMake(53.37, 84.04)];
		[path addCurveToPoint:CGPointMake(43.19, 77.48) controlPoint1:CGPointMake(46.13, 84.04) controlPoint2:CGPointMake(43.19, 81.1)];
		[path closePath];

		_shape1.path = path.CGPath;
		[path release];
		_shape1.strokeColor = [UIColor whiteColor].CGColor;
		_shape1.fillColor = [UIColor whiteColor].CGColor;
		_shape1.lineCap = kCALineCapRound;
		_shape1.lineJoin = kCALineJoinRound;
		if (viewStyle != CLASSIC)
			_shape1.lineWidth = 4.0;
		else
			_shape1.lineWidth = 0.5;
		_shape1.contentsScale = screenScale;


		_shape2 = [[CAShapeLayer alloc] init];
		_shape2.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);

		path = [[UIBezierPath alloc] init];
		[path moveToPoint:CGPointMake(40.4, 79.14)];
		[path addLineToPoint:CGPointMake(58.61, 97.34)];
		[path moveToPoint:CGPointMake(59.1, 79.14)];
		[path addLineToPoint:CGPointMake(51.44, 86.78)];
		[path moveToPoint:CGPointMake(48.06, 90.16)];
		[path addLineToPoint:CGPointMake(40.61, 97.63)];

		_shape2.path = path.CGPath;
		[path release];
		_shape2.strokeColor = [UIColor whiteColor].CGColor;
		_shape2.fillColor = [[UIColor clearColor] CGColor];
		if (viewStyle != CLASSIC)
			_shape2.lineWidth = 6.0;
		else
			_shape2.lineWidth = 3.0;
		_shape2.contentsScale = screenScale;


		[_shape0 addSublayer:_shape1];
		[_shape0 addSublayer:_shape2];

		[_iconView.layer addSublayer:_shape0];
		_shape0.position = CGPointMake(50.0, 0.0);

		if (viewStyle != CLASSIC)
			_iconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.22);
		else
			_iconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.825, 0.825);

		isRingerIcon = YES;

	}

}

-(void)_bellIconUpdate {

	_shape1.opacity = 1.0;
	_shape2.opacity = 0.0;

	if (_muteSwitchMoved) {
		if (_isRingerSilent) {
			_shape1.opacity = 0.0;
			_shape2.opacity = 1.0;
			[self _basicAnimationFor:_shape2 withKeyPath:@"strokeEnd" andDuration:0.5 beginIn:0 toValue:1.0 isDismissal:NO];
		}
		else {
			CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc] init];
			[animation setKeyPath:@"transform.rotation.z"];
			animation.removedOnCompletion = NO;
			animation.fillMode = kCAFillModeForwards;
			animation.duration = 0.33;
			animation.beginTime = CACurrentMediaTime() + 0.17;
			animation.values = @[@(-7.5 * M_PI / 180.0), @(7.5 * M_PI / 180.0), @(-7.5 * M_PI / 180.0), @(7.5 * M_PI / 180.0), @(0.0)];
			[_shape0 addAnimation:animation forKey:@"animation"];
			[animation release];

			CAKeyframeAnimation *animation2 = [[CAKeyframeAnimation alloc] init];
			[animation2 setKeyPath:@"position.x"];
			animation2.removedOnCompletion = NO;
			animation2.fillMode = kCAFillModeForwards;
			animation2.duration = 0.33;
			animation2.beginTime = CACurrentMediaTime() + 0.17;
			animation2.values = @[@(37.5), @(62.5), @(37.5), @(62.5), @(50.0)];
			[_shape1 addAnimation:animation2 forKey:@"animation2"];
			[animation2 release];
		}
	}

}

-(void)_createNoteIcon {

	if (!_shape0) {

		_shape0 = [[CAShapeLayer alloc] init];
		_shape0.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);

		UIBezierPath* path = [[UIBezierPath alloc] init];
		[path moveToPoint:CGPointMake(51, 4.51)];
		[path addLineToPoint:CGPointMake(51.01, 4.51)];
		[path addCurveToPoint:CGPointMake(46.6, 8.48) controlPoint1:CGPointMake(48.69, 4.39) controlPoint2:CGPointMake(46.72, 6.16)];
		[path addLineToPoint:CGPointMake(46.6, 8.48)];
		[path addLineToPoint:CGPointMake(44.2, 53.51)];
		[path addLineToPoint:CGPointMake(44.2, 53.51)];
		[path addLineToPoint:CGPointMake(44.17, 53.5)];
		[path addCurveToPoint:CGPointMake(16.71, 66.89) controlPoint1:CGPointMake(32.89, 49.62) controlPoint2:CGPointMake(20.6, 55.61)];
		[path addCurveToPoint:CGPointMake(30.11, 94.35) controlPoint1:CGPointMake(12.83, 78.17) controlPoint2:CGPointMake(18.83, 90.46)];
		[path addCurveToPoint:CGPointMake(36.38, 95.51) controlPoint1:CGPointMake(32.13, 95.04) controlPoint2:CGPointMake(34.25, 95.44)];
		[path addCurveToPoint:CGPointMake(58.79, 74.51) controlPoint1:CGPointMake(48.28, 95.96) controlPoint2:CGPointMake(58.17, 86.37)];
		[path addCurveToPoint:CGPointMake(61.36, 25.59) controlPoint1:CGPointMake(59.55, 60.11) controlPoint2:CGPointMake(60.84, 35.4)];
		[path addLineToPoint:CGPointMake(61.36, 25.61)];
		[path addCurveToPoint:CGPointMake(65.67, 21.59) controlPoint1:CGPointMake(61.44, 23.31) controlPoint2:CGPointMake(63.37, 21.51)];
		[path addCurveToPoint:CGPointMake(65.74, 21.59) controlPoint1:CGPointMake(65.7, 21.59) controlPoint2:CGPointMake(65.72, 21.59)];
		[path addLineToPoint:CGPointMake(65.74, 21.59)];
		[path addLineToPoint:CGPointMake(79.25, 22.3)];
		[path addLineToPoint:CGPointMake(79.26, 22.3)];
		[path addCurveToPoint:CGPointMake(83.68, 18.33) controlPoint1:CGPointMake(81.58, 22.42) controlPoint2:CGPointMake(83.56, 20.64)];
		[path addCurveToPoint:CGPointMake(83.68, 18.25) controlPoint1:CGPointMake(83.68, 18.3) controlPoint2:CGPointMake(83.68, 18.28)];
		[path addLineToPoint:CGPointMake(83.68, 18.3)];
		[path addLineToPoint:CGPointMake(84.09, 10.4)];
		[path addLineToPoint:CGPointMake(84.09, 10.39)];
		[path addCurveToPoint:CGPointMake(80.13, 5.98) controlPoint1:CGPointMake(84.21, 8.07) controlPoint2:CGPointMake(82.44, 6.1)];
		[path addCurveToPoint:CGPointMake(80.05, 5.98) controlPoint1:CGPointMake(80.1, 5.98) controlPoint2:CGPointMake(80.08, 5.98)];
		[path addLineToPoint:CGPointMake(80.09, 5.98)];
		[path addLineToPoint:CGPointMake(51, 4.51)];
		[path closePath];

		_shape0.path = path.CGPath;
		[path release];
		_shape0.fillColor = [UIColor whiteColor].CGColor;
		_shape0.lineCap = kCALineCapRound;
		_shape0.lineJoin = kCALineJoinRound;
		_shape0.lineWidth = 1.0;
		_shape0.contentsScale = screenScale;

		[_iconView.layer addSublayer:_shape0];

		_iconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.22, 0.22);

		isRingerIcon = NO;

	}

}

-(void)_createBaseUI {

	_window = [[objc_getClass("SVCWindow") alloc] initWithDebugName:@"SVCWindow"];
	_window.tag = viewStyle;
	_window.frame = referenceBounds;
	[_window setWindowLevel:UIWindowLevelAlert + 201.0];
	
	_rootView = [[UIView alloc] initWithFrame:_window.frame];
	[_window addSubview:_rootView];
	
	_containerView = [[UIView alloc] init];
	_containerView.frame = _window.frame;
	[_rootView addSubview:_containerView];

	UIBlurEffect *blur = [UIBlurEffect effectWithStyle:[self _backgroundEffect]];
	_effectView0 = [[UIVisualEffectView alloc] initWithEffect:blur];
	_effectView0.userInteractionEnabled = NO;

	UIVibrancyEffect *vibrancy0 = [UIVibrancyEffect effectForBlurEffect:blur style:UIVibrancyEffectStyleFill];
	_effectView1 = [[UIVisualEffectView alloc] initWithEffect:vibrancy0];

	UIVibrancyEffect *vibrancy1 = [UIVibrancyEffect effectForBlurEffect:blur style:UIVibrancyEffectStyleLabel];
	_effectView2 = [[UIVisualEffectView alloc] initWithEffect:vibrancy1];

	_effectView0.frame = _containerView.frame;
	_effectView1.frame = _effectView0.frame;
	_effectView2.frame = _effectView0.frame;

	_effectView0.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin);

	_effectView1.autoresizingMask = _effectView0.autoresizingMask;
	_effectView2.autoresizingMask = _effectView0.autoresizingMask;

	[_effectView0.contentView addSubview:_effectView1];
	[_effectView1.contentView addSubview:_effectView2];
	[_containerView addSubview:_effectView0];

	if (viewStyleLabelCount) {
		_label1 = [[UILabel alloc] init];
		_label1.textAlignment = NSTextAlignmentCenter;
		_label1.textColor = [UIColor whiteColor];
		_label1.adjustsFontSizeToFitWidth = YES;
		_label1.minimumScaleFactor = 0.1;
		[_effectView2.contentView addSubview:_label1];
		_silentString = [[NSString alloc] initWithString:[[NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"] localizedStringForKey:@"RINGER_SILENT" value:@"Silent Mode" table:@"SpringBoard"]];
		_muteString = [[NSString alloc] initWithString:[[NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"] localizedStringForKey:@"MUTE_VOLUME" value:@"Mute" table:@"SpringBoard"]];
		if (viewStyleLabelCount == 2){
			_label0 = [[UILabel alloc] init];
			_label0.textAlignment = NSTextAlignmentCenter;
			_label0.textColor = [UIColor whiteColor];
			_label0.adjustsFontSizeToFitWidth = YES;
			_label0.minimumScaleFactor = 0.1;
			[_effectView2.contentView addSubview:_label0];
			_volumeString = [[NSString alloc] initWithString:[[NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"] localizedStringForKey:@"VOLUME_VOLUME" value:@"Volume" table:@"SpringBoard"]];
			_ringerString = [[NSString alloc] initWithString:[[NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"] localizedStringForKey:@"RINGER_VOLUME" value:@"Ringer" table:@"SpringBoard"]];
		}
	}
	if (viewStyle != DISC) {

		_volumePanView = [[UIView alloc] init];
		_volumePanView.layer.masksToBounds = YES;
		_volumePanView.layer.continuousCorners = YES;
		UIPanGestureRecognizer *volumePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_volumeViewPanned:)];
		[_volumePanView addGestureRecognizer:volumePanRecognizer];
		[volumePanRecognizer release];

		_volumeView = [[UIView alloc] init];
		_volumeView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin);
		_volumeView.backgroundColor = [UIColor whiteColor];
		[_volumePanView addSubview:_volumeView];

		if (viewStyleIncludesThemes) {
			_volumePanView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.3];
			if (viewStyle == VIDEOPLAYER) {
				_contentContainerView0 = [[UIView alloc] init];
				[_contentContainerView0 addSubview:_volumePanView];
				[_effectView2.contentView addSubview:_contentContainerView0];
			}
			else {
				if (viewStyle == WINDOWS10)
					[_effectView0.contentView addSubview:_volumePanView];
				else
					[_effectView2.contentView addSubview:_volumePanView];
			}
		}
		else {
			if (viewStyle == WINDOWS10 || viewStyle == ANDROID) {
				_contentContainerView0 = [[UIView alloc] init];
				[_contentContainerView0 addSubview:_volumePanView];
				[_effectView0.contentView addSubview:_contentContainerView0];
			}
			else
				[_effectView0.contentView addSubview:_volumePanView];
		}
	}

	if (viewStyleUsesIcons) {
		_iconView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
		if (viewStyleIncludesThemes || viewStyle == ANDROID){
			[_effectView2.contentView addSubview:_iconView];
			[_effectView2.contentView bringSubviewToFront:_iconView];
		}
		else {
			[_effectView0.contentView addSubview:_iconView];
			[_effectView0.contentView bringSubviewToFront:_iconView];
		}
	}

	if (viewStyleIncludesThemes && backgroundType == OLED) {
		[_effectView0 setAllowsBlurring:NO];
		[_effectView1 setAllowsBlurring:NO];
		[_effectView1 setAllowsBlurring:NO];
		_effectView0.backgroundColor = [UIColor blackColor];
	}

}

-(void)_createUI {

	[self _createBaseUI];

	if (viewStyle == CLASSIC)
		[self _createClassicUI];
	else if (viewStyle == BIGNOTCHY)
		[self _createBigNotchyUI];
	else if (viewStyle == NOTCHY)
		[self _createNotchyUI];
	else if (viewStyle == PILL)
		[self _createPillUI];
	else if (viewStyle == DISC)
		[self _createDiscUI];
	else if (viewStyle == MINIMAL)
		[self _createMinimalUI];
	else if (viewStyle == VIDEOPLAYER)
		[self _createVideoPlayerUI];
	else if (viewStyle == WINDOWS10)
		[self _createWindows10UI];
	else if (viewStyle == ANDROID)
		[self _createAndroidUI];
	else if (viewStyle == TRIANGLE)
		[self _createTriangleUI];
	else if (viewStyle == BOTTOMBAR)
		[self _createBottomBarUI];

	if (viewStyle == WINDOWS10)
		_volumeView.frame = CGRectMake(0.0, _volumePanView.frame.size.height - 10.0 - ((_volumePanView.frame.size.height - 10.0) * _volume), _volumePanView.frame.size.width, _volumePanView.frame.size.height * _volume + 10.0);
	else if (viewStyle == ANDROID)
		_volumeView.frame = CGRectMake(0.0, _volumePanView.frame.size.height - _volumePanView.frame.size.height * _volume, _volumePanView.frame.size.width, _volumePanView.frame.size.height * _volume);
	else
		_volumeView.frame = CGRectMake(0.0, 0.0, _volumePanView.frame.size.width * _volume, _volumePanView.frame.size.height);

	[self _updateUI];
	long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
	[self reorientUIForOrientation:orientation withAnimationDuration:0.0];

}

-(void)_updateBaseUI {

	NSTimeInterval duration = 0.2;
	if (viewStyle != DISC && previousIsRingerHUD != _isRingerHUD) 
		duration = 0.0;

	if (_isRingerHUD) {
		if (viewStyleUsesIcons) {
			if (!isRingerIcon && _shape0) {
				if (viewStyle != ANDROID) {
					[_shape4 release];
					[_shape3 release];
					[_shape2 release];
					[_shape1 release];
				}
				[_shape0 removeFromSuperlayer];
				[_shape0 release];
				_shape0 = nil;
			}
			[self _createBellIcon];
			[self _bellIconUpdate];
		}
		if (viewStyleLabelCount) {
			if (viewStyleLabelCount == 2)
				_label0.text = _ringerString;
			_label1.text = _silentString;
		}
		_volumePanView.alpha = 1.0;
		_label1.alpha = 0.0;
		if (_muteSwitchMoved && _isRingerSilent) {
			_volumePanView.alpha = 0.0;
			_label1.alpha = 1.0;
		}
	}
	else {
		if (viewStyleUsesIcons) {
			if (isRingerIcon && _shape0) {
				[_shape2 release];
				[_shape1 release];
				[_shape0 removeFromSuperlayer];
				[_shape0 release];
				_shape0 = nil;
			}
			if (viewStyle != ANDROID) {
				[self _createSpeakerIcon];
				[self _speakerIconUpdate];
			}
			else
				[self _createNoteIcon];
		}
		if (viewStyleLabelCount) {
			if (viewStyleLabelCount == 2)
				_label0.text = _volumeString;
			_label1.text = _muteString;
		}
		_volumePanView.alpha = 1.0;
		_label1.alpha = 0.0;
		if (!_volume) {
			_volumePanView.alpha = 0.0;
			_label1.alpha = 1.0;
		}
	}

	[UIView animateWithDuration:duration
	delay:0.0
	options:UIViewAnimationOptionAllowUserInteraction
	animations:^{
		if (viewStyle == WINDOWS10) {
			_volumeView.frame = CGRectMake(0.0, _volumePanView.frame.size.height - 10.0 - ((_volumePanView.frame.size.height - 10.0) * _volume), _volumePanView.frame.size.width, _volumePanView.frame.size.height * _volume + 10.0);
			_contentView0.frame = CGRectMake(0.0, _volumeView.frame.origin.y, 12.5, 10.0);
		}
		else if (viewStyle == ANDROID) {
			_volumeView.frame = CGRectMake(0.0, _volumePanView.frame.size.height - _volumePanView.frame.size.height * _volume, _volumePanView.frame.size.width, _volumePanView.frame.size.height * _volume);
			_contentContainerView1.frame = CGRectMake(25.0, _volumePanView.frame.origin.y + _volumeView.frame.origin.y - 5.0, 10.0, 10.0);
		}
		else {
			_volumeView.frame = CGRectMake(0.0, 0.0, _volumePanView.frame.size.width * _volume, _volumePanView.frame.size.height);
			if (viewStyle == VIDEOPLAYER)
				_contentView0.frame = CGRectMake(_volumeView.frame.size.width + 10 - 5.0, _contentView0.frame.origin.y, _contentView0.frame.size.width, _contentView0.frame.size.height);
		}	
	}
	completion:^ (BOOL finished) {}];

	if (viewStyle != DISC)
		previousIsRingerHUD = _isRingerHUD;
	
}

-(void)_updateUI {

	if (lockscreenVolume && wakeScreen && oledLockScreenVolume && [[objc_getClass("SBLockScreenManager") sharedInstance] isLockScreenActive] && didWakeScreen)
		_window.backgroundColor = [UIColor blackColor];
	else
		_window.backgroundColor = [UIColor clearColor];

	[self _updateBaseUI];

	if (viewStyle == CLASSIC)
		[self _updateClassicUI];
	else if (viewStyle == BIGNOTCHY)
		[self _updateBigNotchyUI];
	else if (viewStyle == NOTCHY)
		[self _updateNotchyUI];
	else if (viewStyle == PILL)
		[self _updatePillUI];
	else if (viewStyle == DISC)
		[self _updateDiscUI];
	else if (viewStyle == MINIMAL)
		[self _updateMinimalUI];
	else if (viewStyle == VIDEOPLAYER)
		[self _updateVideoPlayerUI];
	else if (viewStyle == WINDOWS10)
		[self _updateWindows10UI];
	else if (viewStyle == ANDROID)
		[self _updateAndroidUI];
	else if (viewStyle == ANDROID)
		[self _updateAndroidUI];
	else if (viewStyle == TRIANGLE)
		[self _updateTriangleUI];
	else if (viewStyle == BOTTOMBAR)
		[self _updateBottomBarUI];

}

-(CGAffineTransform)_windowTransformForOrientation:(long long)orientation {

	if (orientation == 2)
		return CGAffineTransformRotate(CGAffineTransformIdentity, 180.0 * M_PI / 180.0);
	else if (orientation == 3)
		return CGAffineTransformRotate(CGAffineTransformIdentity, 90.0 * M_PI / 180.0);
	else if (orientation == 4)
		return CGAffineTransformRotate(CGAffineTransformIdentity, -90.0 * M_PI / 180.0);
	return CGAffineTransformIdentity;

}

-(void)reorientUIForOrientation:(long long)orientation withAnimationDuration:(NSTimeInterval)duration {

	[UIView animateWithDuration:duration
	delay:0.0
	options:UIViewAnimationOptionAllowUserInteraction
	animations:^{

		_window.transform = [self _windowTransformForOrientation:orientation];
		_window.frame = referenceBounds;
		_rootView.frame = [[UIScreen mainScreen] bounds];

		if (viewStyle == CLASSIC)
			[self _reorientClassicUIForOrientation:orientation];
		else if (viewStyle == BIGNOTCHY)
			[self _reorientBigNotchyUIForOrientation:orientation];
		else if (viewStyle == NOTCHY)
			[self _reorientNotchyUIForOrientation:orientation];
		else if (viewStyle == PILL)
			[self _reorientPillUIForOrientation:orientation];
		else if (viewStyle == DISC)
			[self _reorientDiscUIForOrientation:orientation];
		else if (viewStyle == MINIMAL)
			[self _reorientMinimalUIForOrientation:orientation];
		else if (viewStyle == VIDEOPLAYER)
			[self _reorientVideoPlayerUIForOrientation:orientation];
		else if (viewStyle == WINDOWS10)
			[self _reorientWindows10UIForOrientation:orientation];
		else if (viewStyle == ANDROID)
			[self _reorientAndroidUIForOrientation:orientation];
		else if (viewStyle == TRIANGLE)
			[self _reorientTriangleUIForOrientation:orientation];
		else if (viewStyle == BOTTOMBAR)
			[self _reorientBottomBarUIForOrientation:orientation];
		
	}
	completion:^ (BOOL finished) {}];

}

-(void)_autoDismissUIAfter:(NSTimeInterval)sec {

	if (viewStyle == CLASSIC)
		[self _autoDismissClassicUIAfter:sec];
	else if (viewStyle == BIGNOTCHY)
		[self _autoDismissBigNotchyUIAfter:sec];
	else if (viewStyle == NOTCHY)
		[self _autoDismissNotchyUIAfter:sec];
	else if (viewStyle == PILL)
		[self _autoDismissPillUIAfter:sec];
	else if (viewStyle == DISC)
		[self _autoDismissDiscUIAfter:sec];
	else if (viewStyle == MINIMAL)
		[self _autoDismissMinimalUIAfter:sec];
	else if (viewStyle == VIDEOPLAYER)
		[self _autoDismissVideoPlayerUIAfter:sec];
	else if (viewStyle == WINDOWS10)
		[self _autoDismissWindows10UIAfter:sec];
	else if (viewStyle == ANDROID)
		[self _autoDismissAndroidUIAfter:sec];
	else if (viewStyle == TRIANGLE)
		[self _autoDismissTriangleUIAfter:sec];
	else if (viewStyle == BOTTOMBAR)
		[self _autoDismissBottomBarUIAfter:sec];

}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {

	if (flag) {
		if (lockscreenVolume && wakeScreen && oledLockScreenVolume && [[objc_getClass("SBLockScreenManager") sharedInstance] isLockScreenActive] && didWakeScreen && _window.backgroundColor == [UIColor blackColor]) {
			[[objc_getClass("SBLockScreenManager") sharedInstance] lockUIFromSource:1 withOptions:nil];
			[[objc_getClass("SBScreenWakeAnimationController") sharedInstance] sleepForSource:8 completion:^{ didWakeScreen = NO; [self releaseObjects]; }];
			
		}
		else
			[self releaseObjects];
	}

}

-(void)handleHomeScreenPresence {

	if (lockscreenVolume && wakeScreen && oledLockScreenVolume && ![[objc_getClass("SBLockScreenManager") sharedInstance] isLockScreenActive] && _window.backgroundColor == [UIColor blackColor]) {
		didWakeScreen = NO;
		_window.backgroundColor = [UIColor clearColor];
	}

}

-(void)presentUI {

	if (objc_getClass("SVMController") && [objc_getClass("SVMController") performSelector:@selector(isUIPresent)])
		return;

	[self _performHaptic];

	if (lockscreenVolume && wakeScreen && ![[[objc_getClass("SBLockScreenManager") sharedInstance] valueForKey:@"_isScreenOn"] boolValue]) {
		if (oledLockScreenVolume)
			didWakeScreen = YES;
		[[objc_getClass("SBLockScreenManager") sharedInstance] unlockUIFromSource:1 withOptions:@{@"SBUIUnlockOptionsStartFadeInAnimation" : @(0), @"SBUIUnlockOptionsTurnOnScreenFirstKey" : @(1)}];
	}

	if (!_window) {
		[self _createUI];
		[_window makeKeyAndVisible];
		_window.alpha = firstPressVisibility;
		[self _autoDismissUIAfter:autoDismissDelay * firstPressDismissDelay];
	}
	else  {
		[self _updateUI];
		_window.alpha = 1.0;
		[self _autoDismissUIAfter:autoDismissDelay];
	}

	if (!_window.windowLevel)
		_window.windowLevel = UIWindowLevelAlert + 1.0;

	if (makeChangesSilently)
		_window.windowLevel = 0.0;

}

-(void)_createClassicUI {

	_containerView.frame = CGRectMake(0.0, 0.0, 155.0, 155.0);
	_containerView.layer.shadowColor = [UIColor blackColor].CGColor;
	_containerView.layer.shadowOffset = CGSizeMake(1.5, 2.0);
	_containerView.layer.shadowOpacity = 0.33;
	_containerView.layer.shadowRadius = 1.25;

	_effectView0.layer.cornerRadius = _effectView0.frame.size.width * 0.1;
	_effectView0.layer.masksToBounds = YES;
	_effectView0.layer.continuousCorners = YES;

	_label0.frame = CGRectMake(0.0, 7.5, _containerView.frame.size.width, 20.0);
	_label0.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];

	_label1.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, 15.0);
	_label1.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];

	_volumePanView.frame = CGRectMake(13.0, _containerView.frame.size.width - 20.0, _containerView.frame.size.height - 26.0, 5.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;

	_label1.center = _volumePanView.center;
	_iconView.center = _containerView.center;

}

-(void)_updateClassicUI {

	// Nothing to handle at the moment.

}

-(void)_reorientClassicUIForOrientation:(long long)orientation {

	_containerView.center = _rootView.center;

}

-(void)_autoDismissClassicUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_window.layer withKeyPath:@"opacity" andDuration:1.0 beginIn:sec toValue:0.0 isDismissal:YES];

}


-(void)_createBigNotchyUI {

	CGFloat radius = [[UIScreen mainScreen] _displayCornerRadius];

	_containerView.frame = CGRectMake(0.0, -sbHeight - 20.0, 2.0 * notchFrame.origin.x + notchFrame.size.width, sbHeight + 20.0);
	_containerView.layer.maskedCorners = (kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
	_containerView.layer.cornerRadius = !radius ? _containerView.frame.size.height * 0.5 : radius;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_label1.frame = CGRectMake(4.0, 0.0, notchFrame.origin.x, sbHeight);

	_label0.frame = CGRectMake(notchFrame.origin.x + notchFrame.size.width - 4.0, 0.0, notchFrame.origin.x, sbHeight);
	_label0.font = [UIFont systemFontOfSize:sbHeight > 20.0 ? 16.0 : 14.0 weight:UIFontWeightSemibold];

	_volumePanView.frame = CGRectMake(notchFrame.origin.x / 2.0, sbHeight, notchFrame.origin.x + notchFrame.size.width, 5.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;

}

-(void)_updateBigNotchyUI {

	if (_containerView.frame.origin.y) {
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, sbHeight + 20.0); }
		completion:^ (BOOL finished) {}];
	}

	_label1.font = [UIFont systemFontOfSize:sbHeight > 20.0 ? 14.0 : 12.0 weight:UIFontWeightSemibold];

	_volumePanView.alpha = 1.0;

	if ((_isRingerHUD && _muteSwitchMoved && _isRingerSilent) || (!_isRingerHUD && !_volume))
		return;

	_label1.font = [UIFont systemFontOfSize:sbHeight > 20.0 ? 16.0 : 14.0 weight:UIFontWeightSemibold];
	_label1.text = [NSString stringWithFormat:@"%d %%", (int)roundf(_volume * 100.0)];
	_label1.alpha = 1.0;

}

-(void)_reorientBigNotchyUIForOrientation:(long long)orientation {

	_containerView.center = CGPointMake(_rootView.frame.size.width / 2.0, _containerView.center.y);

}

-(void)_autoDismissBigNotchyUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"position.y" andDuration:0.3 beginIn:sec+0.3 toValue:-sbHeight-20.0 isDismissal:YES];

}


-(void)_createNotchyUI {

	CGFloat radius = [objc_getClass("_UIStatusBarVisualProvider_Split") notchBottomCornerRadius];

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - notchFrame.size.width / 2.0, - 30.0 - notchFrame.size.height, notchFrame.size.width, 30.0 + notchFrame.size.height);
	_containerView.layer.maskedCorners = (kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner);
	_containerView.layer.cornerRadius = radius;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_label1.frame = CGRectMake(0.0, 0.0, 2.0 * _containerView.frame.size.width / 3.0, 30.0);
	_label1.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];

	_volumePanView.frame = CGRectMake(notchFrame.size.width / 4.0, notchFrame.size.height + 12.0, 3 * notchFrame.size.width / 4.0 - 15.0, 5.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;

	_label1.center = CGPointMake(_containerView.frame.size.width / 2.0, _volumePanView.center.y);
	_iconView.center = CGPointMake(25.0, _volumePanView.center.y);

}

-(void)_updateNotchyUI {

	if (_containerView.frame.origin.y) {
		long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.frame = CGRectMake(_rootView.frame.size.width / 2 - _containerView.frame.size.width / 2.0, orientation == 1 && isNotchDevice ? 0.0 :-30.0, _containerView.frame.size.width, _containerView.frame.size.height); }
		completion:^ (BOOL finished) {}];
	}

}

-(void)_reorientNotchyUIForOrientation:(long long)orientation {

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2 - _containerView.frame.size.width / 2.0, orientation == 1 && isNotchDevice ? 0.0 :-30.0, _containerView.frame.size.width, _containerView.frame.size.height);
	
}

-(void)_autoDismissNotchyUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"position.y" andDuration:0.3 beginIn:sec+0.3 toValue:-30.0-notchFrame.size.height isDismissal:YES];

}


-(void)_createPillUI {

	_containerView.frame = CGRectMake(17.5, 7.5, notchFrame.origin.x - 25.0, notchFrame.size.height);
	_containerView.layer.cornerRadius = _containerView.frame.size.height * 0.5;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_volumePanView.frame = CGRectMake(1.0, 1.0, _containerView.frame.size.width - 2.0, _containerView.frame.size.height - 2.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;
	_volumePanView.layer.masksToBounds = YES;
	_volumePanView.layer.continuousCorners = YES;

	_volumeView.backgroundColor = [UIColor colorWithRed:0.1 green:0.9 blue:0.1 alpha:0.7];

	_iconView.center = CGPointMake(_containerView.frame.size.width / 2.0, _containerView.frame.size.height / 2.0);

	_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 1.0);

}

-(void)_updatePillUI {

	if (!_containerView.transform.a)
		[UIView animateWithDuration:0.2
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
		completion:^(BOOL finished) {}];

	_volumeView.alpha = 1.0;

}

-(void)_reorientPillUIForOrientation:(long long)orientation {

	// Nothing to handle at the moment.

}

-(void)_autoDismissPillUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"transform.scale.x" andDuration:0.2 beginIn:sec+0.2 toValue:0.0 isDismissal:YES];

}


-(void)_createDiscUI {

	_containerView.frame = CGRectMake(-notchFrame.origin.x / 2.0, notchFrame.size.height, notchFrame.origin.x / 2.0, notchFrame.origin.x / 2.0);
	_containerView.layer.cornerRadius = _containerView.frame.size.height * 0.5;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_shape = [[CAShapeLayer alloc] init];
	_shape.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height);

	UIBezierPath *arcPath = [[UIBezierPath alloc] init];  
	[arcPath addArcWithCenter:CGPointMake(_containerView.frame.size.width / 2.0, _containerView.frame.size.height / 2.0) radius:_containerView.frame.size.width / 2.0 - 3.0 startAngle:135.0 * M_PI / 180.0 endAngle:405 * M_PI / 180.0 clockwise:YES];

	_shape.path = arcPath.CGPath;
	[arcPath release];
	_shape.strokeColor = [[UIColor whiteColor] CGColor];
	_shape.fillColor = [[UIColor clearColor] CGColor];
	_shape.lineWidth = 2.0;
	_shape.strokeEnd = _volume;
	_shape.contentsScale = screenScale;

	[_effectView2.contentView.layer addSublayer:_shape];

	_iconView.center = CGPointMake(_containerView.frame.size.width / 2.0, _containerView.frame.size.height / 2.0);

	_containerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, - M_PI);

}

-(void)_updateDiscUI {

	if (!_containerView.layer.animationKeys)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{
			_containerView.frame = CGRectMake(notchFrame.origin.x / 4.0, notchFrame.size.height, notchFrame.origin.x / 2.0, notchFrame.origin.x / 2.0);
			_containerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0);
		}
		completion:^ (BOOL finished) {}];

	if (previousIsRingerHUD != _isRingerHUD) {
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		_shape.strokeEnd = _volume;
		[CATransaction commit];
	}
	else
		_shape.strokeEnd = _volume;

	previousIsRingerHUD = _isRingerHUD;

}

-(void)_reorientDiscUIForOrientation:(long long)orientation {

	// Nothing to handle at the moment.

}

-(void)_autoDismissDiscUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"position.x" andDuration:0.3 beginIn:sec+0.3 toValue:-notchFrame.origin.x/2.0 isDismissal:YES];
	[self _basicAnimationFor:_containerView.layer withKeyPath:@"transform.rotation" andDuration:0.3 beginIn:sec+0.3 toValue:-M_PI isDismissal:NO];
	

}


-(void)_createMinimalUI {

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - (notchFrame.size.width - 40.0) / 2.0, notchFrame.size.height + 5.0, notchFrame.size.width - 40.0, 6.0);
	_containerView.layer.cornerRadius = _containerView.frame.size.height * 0.5;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;
	_containerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];

	_volumePanView.frame = CGRectMake(1.0, 1.0, _containerView.frame.size.width - 2.0, _containerView.frame.size.height - 2.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;
	_volumePanView.layer.masksToBounds = YES;
	_volumePanView.layer.continuousCorners = YES;

	_label1.frame = CGRectMake(0.0, 0.0, notchFrame.size.width - 80.0, 12.5);
	_label1.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightSemibold];
	_label1.center = CGPointMake(_containerView.frame.size.width / 2.0, _containerView.frame.size.height / 2.0);

	_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 1.0);

}

-(void)_updateMinimalUI {

	if (!_containerView.transform.a)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
		completion:^ (BOOL finished) {}];

	[UIView animateWithDuration:0.2
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{
			if ((_isRingerHUD && _muteSwitchMoved && _isRingerSilent) || (!_isRingerHUD && !_volume))
				_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - (notchFrame.size.width - 80.0) / 2.0, _containerView.frame.origin.y, notchFrame.size.width - 80.0, 12.5);
			else
				_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - (notchFrame.size.width - 40.0) / 2.0, _containerView.frame.origin.y, notchFrame.size.width - 40, 6.0);
			_containerView.layer.cornerRadius = _containerView.frame.size.height * 0.5;
			_label1.center = CGPointMake(_containerView.frame.size.width / 2.0, _containerView.frame.size.height / 2.0);
		}
		completion:^ (BOOL finished) {}];

}

-(void)_reorientMinimalUIForOrientation:(long long)orientation {

	_containerView.frame = _containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - _containerView.frame.size.width / 2.0, orientation == 1 && isNotchDevice ? notchFrame.size.height + 2.5 :2.5, _containerView.frame.size.width, _containerView.frame.size.height);
	
}

-(void)_autoDismissMinimalUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"transform.scale.x" andDuration:0.3 beginIn:sec+0.3 toValue:0.0 isDismissal:YES];

}


-(void)_createVideoPlayerUI {

	_containerView.frame = CGRectMake(_rootView.frame.size.width - 155.0 - 10.0, sbHeight, 155.0, 40.0);
	_containerView.layer.cornerRadius = 40.0 / 3.0;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_contentContainerView0.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, 40.0);

	_volumePanView.frame = CGRectMake(10.0, _containerView.frame.size.height / 2.0 - 2.5, 2.0 * _containerView.frame.size.width / 3.0 - 5.0, 5.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;
	_volumePanView.layer.masksToBounds = YES;
	_volumePanView.layer.continuousCorners = YES;
	
	_contentView0 = [[UIView alloc] initWithFrame:CGRectMake(_volumeView.frame.size.width + 10 - 5.0, _volumePanView.frame.origin.y - 2.5, 10.0, 10.0)];
	_contentView0.layer.cornerRadius = _contentView0.frame.size.height * 0.5;
	_contentView0.layer.masksToBounds = YES;
	_contentView0.layer.continuousCorners = YES;
	_contentView0.backgroundColor = [UIColor whiteColor];
	[_contentContainerView0 addSubview:_contentView0];

	_label1.frame = CGRectMake(10.0, 40.0 / 2.0 - 10.0, 2.0 * _containerView.frame.size.width / 3.0 - 5.0, 20.0);
	_label1.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];

	_iconView.center = CGPointMake(_containerView.frame.size.width - 20.0, _volumePanView.frame.origin.y + _volumePanView.frame.size.height / 2.0);

	_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.0);


}

-(void)_updateVideoPlayerUI {

	if (!_containerView.transform.d)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
		completion:^ (BOOL finished) {}];

	if ((_isRingerHUD && _muteSwitchMoved && _isRingerSilent) || (!_isRingerHUD && !_volume))
		_contentView0.alpha = 0.0;
	else
		_contentView0.alpha = 1.0;

}

-(void)_reorientVideoPlayerUIForOrientation:(long long)orientation {

	_containerView.frame = CGRectMake(_rootView.frame.size.width - 155.0 - 10.0, [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] ? sbHeight : orientation == 1 ? sbHeight : sbHeight / 2.0 , _containerView.frame.size.width, _containerView.frame.size.height);
	
}

-(void)_autoDismissVideoPlayerUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"transform.scale.y" andDuration:0.3 beginIn:sec+0.3 toValue:0.0 isDismissal:YES];

}


-(void)_createWindows10UI {

	_containerView.frame = CGRectMake(0.0, 0.0, 60.0, 60.0 * 2.5);
	long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
	_containerView.center = CGPointMake(-30.0, orientation == 1 ? volumeButtonsCenterY : _rootView.frame.size.height / 2.0);

	_contentContainerView0.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height);

	_volumePanView.frame = CGRectMake(23.75, 15.0, 12.5, 60.0 * 2.5 - 15 - 40);
	_volumePanView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.3];

	_volumeView.backgroundColor = [UIColor colorWithRed:0.0 green:175.0/255.0 blue:1.0 alpha:1.0];

	_contentView0 = [[UIView alloc] initWithFrame:CGRectMake(0.0, _volumeView.frame.origin.y, 12.5, 10.0)];
	_contentView0.backgroundColor = [UIColor whiteColor];
	[_volumePanView addSubview:_contentView0];

	_label1.frame = CGRectMake(0.0, _containerView.frame.size.height - 40.0, _containerView.frame.size.width, 40.0);
	_label1.lineBreakMode = NSLineBreakByWordWrapping;
	_label1.numberOfLines = 0;

}

-(void)_updateWindows10UI {

	if (_containerView.frame.origin.x < 0.0)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{
			long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
			_containerView.center = CGPointMake(isNotchDevice && orientation == 3 ? 55.0 / 2.0 + 5.0 + notchFrame.size.height : 55.0 / 2.0 + 5.0, _containerView.center.y);
		}
		completion:^ (BOOL finished) {}];

	_volumePanView.alpha = 1.0;
	_label1.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];

	if ((_isRingerHUD && _muteSwitchMoved && _isRingerSilent) || (!_isRingerHUD && !_volume))
		return;

	_label1.text = [NSString stringWithFormat:@"%d", (int)roundf(_volume * 100.0)];
	_label1.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
	_label1.alpha = 1.0;

}

-(void)_reorientWindows10UIForOrientation:(long long)orientation {

	_containerView.center = CGPointMake(isNotchDevice && orientation == 3 ? 55.0 / 2.0 + 5.0 + notchFrame.size.height :55.0 / 2.0 + 5.0, orientation == 1 ? volumeButtonsCenterY : orientation == 2 ? _rootView.frame.size.height - volumeButtonsCenterY : _rootView.frame.size.height / 2.0);
	
}

-(void)_autoDismissWindows10UIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"position.x" andDuration:0.3 beginIn:sec+0.3 toValue:-50.0 isDismissal:YES];

}


-(void)_createAndroidUI {

	_containerView.frame = CGRectMake(_rootView.frame.size.width - 65.0, _rootView.frame.size.height / 2.0 - 60.0 * 4.0 / 2.0, 60.0, 60.0 * 4.0);
	_containerView.layer.cornerRadius = _containerView.frame.size.width * 0.2;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_contentContainerView0.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height);

	_volumePanView.frame = CGRectMake(29.0, 35.0, 2.0, _containerView.frame.size.height - 40.0 - 40.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.width * 0.5;
	_volumePanView.layer.masksToBounds = YES;
	_volumePanView.layer.continuousCorners = YES;
	_volumePanView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.3];

	_volumeView.backgroundColor = [UIColor colorWithRed:0.0 green:150.0/255.0 blue:1.0 alpha:1.0];

	_contentContainerView1 = [[UIView alloc] initWithFrame:CGRectMake(25.0, _volumePanView.frame.origin.y + _volumeView.frame.origin.y - 5.0, 10.0, 10.0)];
	[_effectView0.contentView addSubview:_contentContainerView1];

	_contentView0 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _contentContainerView1.frame.size.width, _contentContainerView1.frame.size.height)];
	_contentView0.layer.cornerRadius = _contentView0.frame.size.height * 0.5;
	_contentView0.layer.masksToBounds = YES;
	_contentView0.layer.continuousCorners = YES;
	_contentView0.backgroundColor = [UIColor colorWithRed:0.0 green:150.0/255.0 blue:1.0 alpha:1.0];
	[_contentContainerView1 addSubview:_contentView0];

	_label0.frame = CGRectMake(2.5, 0.0, _containerView.frame.size.width - 5.0, 32.5);
	_label0.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightSemibold];
	_label1.hidden = YES;

	_iconView.center = CGPointMake(_containerView.frame.size.width / 2.0, _containerView.frame.size.height - 22.5);

	_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);

}

-(void)_updateAndroidUI {

	if (_containerView.transform.a != 1.0)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
		completion:^ (BOOL finished) {}];

	_volumePanView.alpha = 1.0;

}

-(void)_reorientAndroidUIForOrientation:(long long)orientation {

	_containerView.frame = CGRectMake(orientation == 4 ? _rootView.frame.size.width - 65.0 - notchFrame.size.height :_rootView.frame.size.width - 65.0, _rootView.frame.size.height / 2.0 - 60.0 * 4.0 / 2.0, 60.0, 60.0 * 4.0);
	
}

-(void)_autoDismissAndroidUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"transform.scale" andDuration:0.3 beginIn:sec+0.3 toValue:0.01 isDismissal:YES];

}


-(void)_createTriangleUI {

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - notchFrame.size.width / 2.0, notchFrame.size.height, notchFrame.size.width, notchFrame.size.height);
	_containerView.layer.shadowColor = [UIColor blackColor].CGColor;
	_containerView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
	_containerView.layer.shadowOpacity = 1.0;
	_containerView.layer.shadowRadius = 0.66;

	[_effectView0 setAllowsBlurring:NO];
	[_effectView1 setAllowsBlurring:NO];
	[_effectView1 setAllowsBlurring:NO];

	_volumePanView.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height);

	_shape = [[CAShapeLayer alloc] init];
	_shape.frame = CGRectMake(0.0, 0.0, _containerView.frame.size.width, _containerView.frame.size.height);

	UIBezierPath *trianglePath = [[UIBezierPath alloc] init];
	[trianglePath moveToPoint:CGPointMake(0.0, _containerView.frame.size.height)];
	[trianglePath addLineToPoint:CGPointMake(_containerView.frame.size.width, _containerView.frame.size.height)];
	[trianglePath addLineToPoint:CGPointMake(_containerView.frame.size.width, 0.0)];
	[trianglePath closePath];

	_shape.path = trianglePath.CGPath;
	[trianglePath release];
	_shape.fillColor = [[UIColor whiteColor] CGColor];
	_shape.lineWidth = 0.0;
	_shape.strokeEnd = _volume;
	_shape.contentsScale = screenScale;

	[_volumeView.layer addSublayer:_shape];
	_volumeView.layer.mask = _shape;

	_containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 0.0);

}

-(void)_updateTriangleUI {

	if (!_containerView.transform.d)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0); }
		completion:^ (BOOL finished) {}];

	_volumePanView.alpha = 1.0;

}

-(void)_reorientTriangleUIForOrientation:(long long)orientation {

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 - notchFrame.size.width / 2.0, orientation == 1 ? notchFrame.size.height :2.5, notchFrame.size.width, notchFrame.size.height);
	
}

-(void)_autoDismissTriangleUIAfter:(NSTimeInterval)sec {

	[self _basicAnimationFor:_containerView.layer withKeyPath:@"transform.scale.y" andDuration:0.3 beginIn:sec+0.3 toValue:0.0 isDismissal:YES];

}


-(void)_createBottomBarUI {

	CGFloat radius = [[UIScreen mainScreen] _displayCornerRadius];

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 -  (2.0 * notchFrame.origin.x + notchFrame.size.width) / 2.0, _rootView.frame.size.height, 2.0 * notchFrame.origin.x + notchFrame.size.width, 60.0);
	_containerView.layer.maskedCorners = (kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner);
	_containerView.layer.cornerRadius = !radius ? _containerView.frame.size.height * 0.5 : radius;
	_containerView.layer.masksToBounds = YES;
	_containerView.layer.continuousCorners = YES;

	_volumePanView.frame = CGRectMake(65.0, 28.0, _containerView.frame.size.width - 150.0, 4.0);
	_volumePanView.layer.cornerRadius = _volumePanView.frame.size.height * 0.5;
	_volumePanView.layer.masksToBounds = YES;
	_volumePanView.layer.continuousCorners = YES;

	_iconView.center = CGPointMake(35.0, _containerView.frame.size.height / 2.0);

	_label1.frame = CGRectMake(_containerView.frame.size.width - 80.0, 0.0, 75.0, _containerView.frame.size.height);

}

-(void)_updateBottomBarUI {

	if (_containerView.frame.origin.y == _rootView.frame.size.height)
		[UIView animateWithDuration:0.3
		delay:0.0
		options:UIViewAnimationOptionAllowUserInteraction
		animations:^{ _containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 -  (2.0 * notchFrame.origin.x + notchFrame.size.width) / 2.0, _rootView.frame.size.height - 60.0, _containerView.frame.size.width, _containerView.frame.size.height); }
		completion:^ (BOOL finished) {}];


	_volumePanView.alpha = 1.0;
	_label1.alpha = 1.0;
	_label1.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];

	if ((_isRingerHUD && _muteSwitchMoved && _isRingerSilent) || (!_isRingerHUD && !_volume))
		return;

	_label1.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
	_label1.text = [NSString stringWithFormat:@"%d", (int)roundf(_volume * 100.0)];
	
}

-(void)_reorientBottomBarUIForOrientation:(long long)orientation {

	_containerView.frame = CGRectMake(_rootView.frame.size.width / 2.0 -  (2.0 * notchFrame.origin.x + notchFrame.size.width) / 2.0, _rootView.frame.size.height - 60.0, _containerView.frame.size.width, _containerView.frame.size.height);
}

-(void)_autoDismissBottomBarUIAfter:(NSTimeInterval)sec {

	CABasicAnimation *animation = [[CABasicAnimation alloc] init];
	[animation setKeyPath:@"position.y"];
	animation.duration = 0.3;
	animation.beginTime = CACurrentMediaTime() + sec + 0.3;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.byValue = @(60.0);
	animation.delegate = (id<CAAnimationDelegate>)self;
	[_containerView.layer addAnimation:animation forKey:@"dismissal"];
	[animation release];

}
@end




