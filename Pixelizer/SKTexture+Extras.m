
#import "SKTexture+Extras.h"
#import "UIImage+Extras.h"

@implementation SKTexture (Extras)
+ (SKTexture *)circleTextureWithColor:(UIColor *)color size:(CGSize)size;
{
    UIImage *circle = [UIImage imageWithEllipseOfColor:color size:CGSizeMake(size.width, size.width)];
    SKTexture *texture = [SKTexture textureWithImage:circle];
    texture.filteringMode = SKTextureFilteringNearest;
    return texture;
}

@end
