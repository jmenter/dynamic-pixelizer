
#import "BoxesScene.h"
#import <CoreMotion/CoreMotion.h>
#import "chipmunk.h"
#import "SKAssignableSpriteNode.h"
#import "SKTexture+Extras.h"

@implementation BoxesScene {
    cpSpace *_chipmunkSpace;
    CMMotionManager *_motionManager;
    BOOL _circles;
}

- (instancetype)initWithSize:(CGSize)size image:(UIImage *)image circles:(BOOL)circles;
{
    if (!(self = [super initWithSize:size])) { return nil; }
    self.image = image;
    _circles = circles;
    _motionManager = CMMotionManager.new;
    _motionManager.accelerometerUpdateInterval = 1.f / 60.f;
    [_motionManager startAccelerometerUpdates];
    return self;
}

- (void)didMoveToView:(SKView *)view;
{
    self.view.showsFPS = YES;
    self.view.showsNodeCount = YES;
    self.view.ignoresSiblingOrder = YES;
    
    [self createPhysicsWorld];
    [self createSceneContents];
    self.backgroundColor = UIColor.blackColor;
}

- (void)createPhysicsWorld;
{
    _chipmunkSpace = cpSpaceNew();
    cpFloat wallWidth = 100.f;
    cpVect groundCorners[] = {
        cpv(-wallWidth, -wallWidth),
        cpv(self.view.bounds.size.width + wallWidth, -wallWidth),
        cpv(self.view.bounds.size.width + wallWidth, self.view.bounds.size.height + wallWidth),
        cpv(-wallWidth, self.view.bounds.size.height + wallWidth),
        cpv(-wallWidth, -wallWidth)};
    for (int i = 0; i < 4; i++) {
        cpShape *shape = cpSegmentShapeNew(cpSpaceGetStaticBody(_chipmunkSpace),
                                           groundCorners[i], groundCorners[i + 1], wallWidth + 16);
        cpShapeSetFriction(shape, 1);
        cpSpaceAddShape(_chipmunkSpace, shape);
    }
}

- (void)createSceneContents;
{
    CGImageRef image = self.image.CGImage;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t components = CGImageGetBitsPerPixel(image) / CGImageGetBitsPerComponent(image);
    
    CFDataRef rawData = CGDataProviderCopyData(CGImageGetDataProvider(image));
    UInt8 *imageBuffer = (UInt8 *)CFDataGetBytePtr(rawData);
    
    CGFloat boxWidth = (self.size.width - 16) / width;
    CGFloat pixelWidth = (self.size.width - 16) / width;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            NSInteger pixelIndex = (width * y) + x * components;
            UInt8 pixelComponentB = imageBuffer[pixelIndex];
            UInt8 pixelComponentG = imageBuffer[pixelIndex + 1];
            UInt8 pixelComponentR = imageBuffer[pixelIndex + 2];
            UIColor *color = [UIColor colorWithRed:pixelComponentR / 255.f
                                             green:pixelComponentG / 255.f
                                              blue:pixelComponentB / 255.f alpha:1];
            CGSize boxSize = CGSizeMake(boxWidth, boxWidth);
            SKAssignableSpriteNode *spriteNode = [SKAssignableSpriteNode shapeWithColor:color
                                                                                   size:boxSize
                                                                               circular:_circles];
            spriteNode.pixelXPosition = x;
            spriteNode.pixelYPosition = y;
            spriteNode.position = CGPointMake( (x * pixelWidth) + 16, self.view.bounds.size.height - 58 -  (y * pixelWidth));
            spriteNode.mass = (pixelComponentG / 25.f) + 1;
            [self addChild:spriteNode];
            cpFloat moment;
            cpBody *body;
            cpShape *shape;
            if (_circles) {
                moment = cpMomentForCircle(spriteNode.mass, boxSize.width / 2.f, boxSize.height / 2.f, cpvzero);
                body = cpBodyNew(spriteNode.mass, moment);
                shape = cpCircleShapeNew(body, boxSize.width / 2.f, cpvzero);
            } else {
                moment = cpMomentForBox(spriteNode.mass, boxSize.width, boxSize.height);
                body = cpBodyNew(spriteNode.mass, moment);
                shape = cpBoxShapeNew(body, boxSize.width, boxSize.height, 0.f);
            }
            cpShapeSetFriction(shape, 0.5);
            cpShapeSetElasticity(shape, 0.5);
            cpBodySetPosition(body, spriteNode.position);
            
            cpSpaceAddBody(_chipmunkSpace, body);
            cpSpaceAddShape(_chipmunkSpace, shape);
            
            cpBodySetUserData(body, (__bridge cpDataPointer)spriteNode);
            spriteNode.body = body;
        }
    }
    CFRelease(rawData);
}


- (void)update:(NSTimeInterval)currentTime;
{
    CGImageRef image = self.image.CGImage;
    CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
    CFDataRef rawData = CGDataProviderCopyData(dataProvider);
    const UInt8 *buffer = CFDataGetBytePtr(rawData);
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    size_t components = CGImageGetBitsPerPixel(image) / CGImageGetBitsPerComponent(image);
    cpSpaceSetGravity(_chipmunkSpace, cpv(self.platformSpecificAcceleration.x * 100,
                                          self.platformSpecificAcceleration.y * 100));
    
    cpSpaceStep(_chipmunkSpace, 1.f / 30.f);
    
    BOOL useCircles = _circles;
    BOOL liveColor = self.liveColor;
    cpSpaceEachBody_b(_chipmunkSpace, ^(cpBody *body) {
        SKAssignableSpriteNode *node = (__bridge SKAssignableSpriteNode *)cpBodyGetUserData(body);
        node.position = cpBodyGetPosition(body);
        node.zRotation = cpBodyGetAngle(body);
        if (liveColor) {
            size_t spritePixelX = node.pixelXPosition;
            size_t spritePixelY = node.pixelYPosition;
            
            size_t pixelIndex = (bytesPerRow * spritePixelY) + spritePixelX * components;
            UInt8 pixelComponent = buffer[pixelIndex];
            UInt8 pixelComponent2 = buffer[pixelIndex + 1];
            UInt8 pixelComponent3 = buffer[pixelIndex + 2];
            UIColor *color = [UIColor colorWithRed:pixelComponent3 / 255.f green:pixelComponent2 / 255.f blue:pixelComponent / 255.f alpha:1];

            if (useCircles) {
                node.texture = [SKTexture circleTextureWithColor:color size:node.size];
            } else {
                node.color = color;
            }
        }
    });
    CFRelease(rawData);
}

- (CMAcceleration)platformSpecificAcceleration;
{
#if (TARGET_OS_SIMULATOR)
    return (CMAcceleration){
        UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft ? -1.f :
        UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight ? 1.f : 0.f,
        UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait ? -1.f :
        UIDevice.currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown ? 1.f : 0.f, 0.f};
#endif
    return _motionManager.accelerometerData.acceleration;
}

- (void)dealloc;
{
    [_motionManager stopAccelerometerUpdates];
    cpSpaceEachShape_b(_chipmunkSpace, ^(cpShape *shape) { cpShapeFree(shape); });
    cpSpaceEachBody_b(_chipmunkSpace, ^(cpBody *body) { cpBodyFree(body); });
    cpSpaceFree(_chipmunkSpace);
}

@end
