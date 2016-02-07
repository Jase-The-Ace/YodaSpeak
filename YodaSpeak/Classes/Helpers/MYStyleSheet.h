//
//  MYStyleSheet.h
//  MysteryApplicationiOS
//

@interface MYStyleSheet : NSObject

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)target action:(SEL)selector xOffset:(CGFloat)xOffset;
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage target:(id)target action:(SEL)selector xOffset:(CGFloat)xOffset height:(CGFloat)height width:(CGFloat)width;

@end
