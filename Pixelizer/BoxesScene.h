
#import <SpriteKit/SpriteKit.h>
@import Accelerate;

@interface BoxesScene : SKScene

@property (nonatomic) UIImage *image;
@property BOOL liveColor;

- (instancetype)initWithSize:(CGSize)size image:(UIImage *)image circles:(BOOL)circles;

@end
