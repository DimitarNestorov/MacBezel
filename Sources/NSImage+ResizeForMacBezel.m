#import <MacBezel/NSImage+ResizeForMacBezel.h>
#import <AVFoundation/AVFoundation.h>

#import "Constants.h"

@implementation NSImage (ResizeForMacBezel)

- (NSImage *)resizeForBezel {
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(kMBPaddedSide, kMBPaddedSide)];
	image.template = self.isTemplate;
	
	[image lockFocus];
	const NSGraphicsContext *context = NSGraphicsContext.currentContext;
	context.imageInterpolation = NSImageInterpolationHigh;
	NSSize size = self.size;
	NSRect rect = AVMakeRectWithAspectRatioInsideRect(size, NSMakeRect(kMBImageX, kMBImageY, kMBImageSide, kMBImageSide));
	[self drawInRect:rect fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationCopy fraction:1];
	[image unlockFocus];
	
	return image;
}

@end
