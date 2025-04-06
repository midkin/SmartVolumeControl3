



// #import <stdio.h>
// #import <unistd.h>
// #import <string.h>
// #import "substrate.h"

// void mylog4(const char *mytxt) {

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

// #define NSLog(...) mylog4([[NSString stringWithFormat:__VA_ARGS__] UTF8String])




#import "SVCHelperController.h"
#import <libactivator/libactivator.h>


@implementation SVCHelperController

static SVCHelperController *sharedController = nil;

+(instancetype)sharedInstance {

	if (!sharedController)
		sharedController = [[self alloc] init];

	return sharedController;

}



-(instancetype)init {

	self = [super init];
	if (self) {
		if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
			[[objc_getClass("LAActivator") sharedInstance] registerListener:(id<LAListener>)self forName:@"eu.midkin.smartvolumecontrol3.presenthud"];
		return self;
	}

	return nil;
}

-(void)licenseCheck {

	// Does nothing after publishing the code

}

-(NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {

	if ([listenerName isEqualToString: @"eu.midkin.smartvolumecontrol3.presenthud"])
		return @"SmartVolumeControl";
	else
		return @"Error: Contact dev.";

}

-(NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {

	if ([listenerName isEqualToString: @"eu.midkin.smartvolumecontrol3.presenthud"])
		return @"Present HUD";
	else
		return @"Error: Contact dev.";

}

-(NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {

	if ([listenerName isEqualToString: @"eu.midkin.smartvolumecontrol3.presenthud"])
		return @"Presents Volume HUD";
	else
		return @"Error: Contact dev.";

}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {

	if ([listenerName isEqualToString: @"eu.midkin.smartvolumecontrol3.presenthud"]) {
		[[objc_getClass("AVSystemController") sharedAVSystemController] changeActiveCategoryVolumeBy:0.0];
		[event setHandled: YES];
	}

}

-(NSData *)activator:(LAActivator *)activator requiresSmallIconDataForListenerName:(NSString *)listenerName scale:(CGFloat *)scale {

	if ([listenerName isEqualToString: @"eu.midkin.smartvolumecontrol3.presenthud"])
		return UIImagePNGRepresentation([UIImage imageNamed:@"icon" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SmartVolumeControl3.bundle"]]);
	else
		return nil;

}

@end