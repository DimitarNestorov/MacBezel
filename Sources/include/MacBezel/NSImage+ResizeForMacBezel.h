#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (ResizeForMacBezel)

/// Returns a new @c NSImage appropriately resized for MacBezel
- (NSImage *)resizeForBezel;

@end

NS_ASSUME_NONNULL_END
