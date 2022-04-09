#import <MacBezel/Bezel.h>
#import <QuartzCore/QuartzCore.h>

#import "Constants.h"

BezelShowOptionKey const BezelShowOptionKeyScreen = @"screen";
BezelShowOptionKey const BezelShowOptionKeyLevel = @"level";
BezelShowOptionKey const BezelShowOptionKeyFadeOutDuration = @"fadeOutDuration";
BezelShowOptionKey const BezelShowOptionKeyFadeOutTimingFunctionName = @"fadeOutTimingFunctionName";
BezelShowOptionKey const BezelShowOptionKeyText = @"text";
BezelShowOptionKey const BezelShowOptionKeyVisibleDuration = @"visibleDuration";

@implementation Bezel

+ (void)showImages:(NSArray<NSImage *> *)images options:(nullable NSDictionary<BezelShowOptionKey, id> *)options {
	static NSWindow *currentWindow = nil;
	static NSTimer *currentTimer = nil;
	
	NSScreen *screenOption = options[BezelShowOptionKeyScreen];
	NSScreen *screen = [screenOption.class isSubclassOfClass:NSScreen.class] ? screenOption : NSScreen.mainScreen ?: NSScreen.screens[0];
	if (screen == nil) {
#ifdef DEBUG
		NSLog(@"MacBezel warning: No screen available");
#endif
		return;
	}
	
	NSNumber *levelObject = options[BezelShowOptionKeyLevel];
	CGWindowLevel level = [levelObject.class isSubclassOfClass:NSNumber.class] ? levelObject.intValue : kCGOverlayWindowLevel;
	
	NSNumber *fadeOutDurationObject = options[BezelShowOptionKeyFadeOutDuration];
	NSTimeInterval fadeOutDuration = [fadeOutDurationObject.class isSubclassOfClass:NSNumber.class] ? fadeOutDurationObject.doubleValue : 0.5;
	
	NSNumber *visibleDurationObject = options[BezelShowOptionKeyVisibleDuration];
	NSTimeInterval visibleDuration = [visibleDurationObject.class isSubclassOfClass:NSNumber.class] ? visibleDurationObject.doubleValue : 2;
	
	CAMediaTimingFunction *fadeOutTimingFunction = [CAMediaTimingFunction functionWithName:options[BezelShowOptionKeyFadeOutTimingFunctionName] ?: kCAMediaTimingFunctionDefault];
	
	NSString *text = options[BezelShowOptionKeyText];
	
#ifdef DEBUG
	if (images.count == 0) {
		NSLog(@"MacBezel warning: Images array is empty");
	}
#endif
	
	NSImage *maskImage = [NSImage imageWithSize:NSMakeSize(kMBSide, kMBSide) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
		NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:dstRect xRadius:kMBRadius yRadius:kMBRadius];
		[NSColor.blackColor set];
		[bezierPath fill];
		return YES;
	}];
	
	NSRect screenFrame = screen.frame;
	NSRect rect = NSMakeRect(screenFrame.origin.x + screenFrame.size.width / 2 - kMBSide / 2, screenFrame.origin.y + kMBY, kMBSide, kMBSide);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		@synchronized (self) {
			if (currentWindow != nil) {
				[currentTimer invalidate];
				[currentWindow close];
				currentTimer = nil;
				currentWindow = nil;
			}
		}
		
		NSWindow *window = [[NSWindow alloc] initWithContentRect:rect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
		window.releasedWhenClosed = NO;
		
		/// Xcode uses 101, OSDUIHelper uses 2005
		window.level = level;
		window.ignoresMouseEvents = YES;
		window.backgroundColor = NSColor.clearColor;
		
		NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, kMBSide, kMBSide)];
		if (@available(macOS 10.14, *)) {
			visualEffectView.material = NSVisualEffectMaterialHUDWindow;
		} else {
			/// https://stackoverflow.com/a/26472651/882847
			NSDictionary *globalUserDefaults = [NSUserDefaults.standardUserDefaults persistentDomainForName:NSGlobalDomain];
			NSString *style = globalUserDefaults[@"AppleInterfaceStyle"];
			BOOL isDarkModeOn = style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"];
			visualEffectView.material = isDarkModeOn ? NSVisualEffectMaterialDark : NSVisualEffectMaterialLight;
		}
		visualEffectView.state = NSVisualEffectStateActive;
		visualEffectView.maskImage = maskImage;
		
		for (NSImage *image in images) {
			NSImageView *imageView = [NSImageView imageViewWithImage:image];
			imageView.frame = NSMakeRect(kMBPadding, kMBPadding, kMBPaddedSide, kMBPaddedSide);
			[visualEffectView addSubview:imageView];
		}
		
		if (text) {
			NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, kMBTextY, kMBSide, kMBTextHeight)];
			textField.font = [NSFont systemFontOfSize:kMBTextFontSize];
			textField.textColor = NSColor.controlTextColor;
			textField.stringValue = text;
			textField.alignment = NSTextAlignmentCenter;
			textField.drawsBackground = NO;
			textField.editable = NO;
			textField.bezeled = NO;
			textField.bordered = NO;
			textField.cell.truncatesLastVisibleLine = YES;
			[visualEffectView addSubview:textField];
		}
		
		window.contentView = visualEffectView;
		
		[window orderFront:self];
		
		@synchronized (self) {
			currentWindow = window;
			
			currentTimer = [NSTimer scheduledTimerWithTimeInterval:visibleDuration repeats:NO block:^(NSTimer * _Nonnull timer) {
				@synchronized (self) {
					currentTimer = nil;
				}
				
				[NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
					context.duration = fadeOutDuration;
					context.timingFunction = fadeOutTimingFunction;
					window.animator.alphaValue = 0;
				} completionHandler:^ {
					[window close];
					@synchronized (self) {
						currentWindow = nil;
					}
				}];
			}];
		}
	});
}

+ (void)showImage:(NSImage *)image options:(nullable NSDictionary<BezelShowOptionKey, id> *)options {
	[self showImages:@[image] options:options];
}

@end
