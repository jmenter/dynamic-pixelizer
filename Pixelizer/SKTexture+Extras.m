
#import "SKTexture+Extras.h"
#import "UIImage+Extras.h"

@implementation SKTexture (Extras)

+ (SKTexture *)circleTextureWithColor:(UIColor *)color size:(CGSize)size;
{
    UIImage *circle = [UIImage imageWithEllipseOfSize:CGSizeMake(size.width, size.width) color:color];
    SKTexture *circleTexture = [SKTexture textureWithImage:circle];
    circleTexture.filteringMode = SKTextureFilteringNearest;
    return circleTexture;
}

@end
