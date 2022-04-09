#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * BezelShowOptionKey NS_TYPED_ENUM;

/// @c NSScreen on which to display the bezel
/// 
/// Default is @c NSScreen.mainScreen
FOUNDATION_EXPORT BezelShowOptionKey const BezelShowOptionKeyScreen;

/// @c NSNumber wrapping a @p CGWindowLevel which sets the level of the overlay
///
/// Default is @c kCGOverlayWindowLevel
///
/// Xcode 13 uses @c kCGPopUpMenuWindowLevel
///
/// See more in @c CoreGraphics/CGWindowLevel.h
FOUNDATION_EXPORT BezelShowOptionKey const BezelShowOptionKeyLevel;

/// The duration before the bezel starts fading out
///
/// Swift type is @c TimeInterval
///
/// Objective-C type is @c NSNumber wrapping a @c NSTimeInterval
///
/// Default is @c 2
FOUNDATION_EXPORT BezelShowOptionKey const BezelShowOptionKeyVisibleDuration;

/// The duration of the fade out animation
///
/// Swift type is @c TimeInterval
///
/// Objective-C type is @c NSNumber wrapping a @c NSTimeInterval
///
/// Default is @c 0.5
FOUNDATION_EXPORT BezelShowOptionKey const BezelShowOptionKeyFadeOutDuration;

/// The @c CAMediaTimingFunctionName which will be used for the fade out animation
///
/// Default is @c kCAMediaTimingFunctionDefault
FOUNDATION_EXPORT BezelShowOptionKey const BezelShowOptionKeyFadeOutTimingFunctionName;

/// The text of the bezel
///
/// Swift type is @c String
///
/// Objective-C type is @c NSString
FOUNDATION_EXPORT BezelShowOptionKey const BezelShowOptionKeyText;

@interface Bezel : NSObject

+ (void)showImage:(NSImage *)image options:(nullable NSDictionary<BezelShowOptionKey, id> *)options;

+ (void)showImages:(NSArray<NSImage *> *)images options:(nullable NSDictionary<BezelShowOptionKey, id> *)options;

@end

NS_ASSUME_NONNULL_END
