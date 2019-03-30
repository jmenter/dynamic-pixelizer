
#import "SKAssignableSpriteNode.h"
#import "SKTexture+Extras.h"

@implementation SKAssignableSpriteNode

+ (instancetype)shapeWithColor:(UIColor *)color size:(CGSize)size circular:(BOOL)circular;
{
    return circular ? [SKAssignableSpriteNode circleWithColor:color size:size] :
                      [SKAssignableSpriteNode squareWithColor:color size:size];
}

+ (instancetype)squareWithColor:(UIColor *)color size:(CGSize)size;
{
    return [SKAssignableSpriteNode.alloc initWithColor:color size:size];
}

+ (instancetype)circleWithColor:(UIColor *)color size:(CGSize)size;
{
    return [SKAssignableSpriteNode.alloc initWithTexture:[SKTexture circleTextureWithColor:color size:size]];
}

@end
