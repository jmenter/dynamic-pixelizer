
#import "UIImage+Extras.h"

@implementation UIImage (Extras)

+ (UIImage *)imageWithEllipseOfSize:(CGSize)size color:(UIColor *)color;
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.f, 0.f, size.width, size.height));
    
    CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
    CGContextSetLineWidth(context, 0.5f);
    CGContextMoveToPoint(context, size.width / 2.f, size.height / 2.f);
    CGContextAddLineToPoint(context, size.width, size.height / 2.f);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
