
#import <SpriteKit/SpriteKit.h>
#import "chipmunk.h"

@interface SKAssignableSpriteNode : SKSpriteNode

@property (nonatomic, assign) cpBody *body;
@property (nonatomic, assign) cpFloat mass;

@property NSUInteger pixelXPosition;
@property NSUInteger pixelYPosition;

+ (instancetype)shapeWithColor:(UIColor *)color size:(CGSize)size circular:(BOOL)circular;
+ (instancetype)squareWithColor:(UIColor *)color size:(CGSize)size;
+ (instancetype)circleWithColor:(UIColor *)color size:(CGSize)size;

@end
