
#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "BoxesScene.h"

@import AVFoundation;
@import Accelerate;

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shapeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *liveControl;
@property (weak, nonatomic) IBOutlet SKView *skView;

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDevice *device;
@property (nonatomic) AVCaptureDeviceInput *deviceInput;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property NSUInteger pixelation;

@end

static NSString *kFrontCamera = @"com.apple.avfoundation.avcapturedevice.built-in_video:1";

@implementation ViewController

- (IBAction)sliderChanged:(UISlider *)sender;
{
    self.pixelation = sender.value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pixelation = self.slider.value;
    self.session = AVCaptureSession.new;
    self.device = [AVCaptureDevice deviceWithUniqueID:kFrontCamera];
    if (self.device) {
        
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        [self.session addInput:self.deviceInput];
        AVCaptureVideoDataOutput *output = AVCaptureVideoDataOutput.new;
        
        [self.session addOutput:output];
        
        [output setSampleBufferDelegate:self queue:dispatch_queue_create("cameraQueue", NULL)];
        output.videoSettings = nil;
        [self.session startRunning];
    } else {
        self.imageView.image = [UIImage imageNamed:@"demo"];
    }
    
    self.imageView.layer.magnificationFilter = kCAFilterNearest;
    self.imageView.layer.minificationFilter = kCAFilterNearest;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(imageViewTap:)]];
    self.skView.hidden = YES;
    [self.skView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(skViewTap:)]];
}

- (void)skViewTap:(UITapGestureRecognizer *)tapGR;
{
    if (self.device) { [self.session startRunning]; }
    self.imageView.hidden = NO;
    self.skView.hidden = YES;
    self.slider.enabled = YES;
    self.shapeControl.enabled = YES;

    [self.skView presentScene:[SKScene.alloc initWithSize:CGSizeZero]];
}

- (void)imageViewTap:(UITapGestureRecognizer *)tapGR;
{
    if (!self.liveControl.selectedSegmentIndex) {
        [self.session stopRunning];
    }
    BoxesScene *scene = [BoxesScene.alloc initWithSize:self.skView.bounds.size
                                                 image:self.imageView.image
                         circles:self.shapeControl.selectedSegmentIndex == 1];
    scene.liveColor = self.liveControl.selectedSegmentIndex;
    [self.skView presentScene:scene];
    self.skView.hidden = NO;
    self.imageView.hidden = YES;
    self.slider.enabled = NO;
    self.shapeControl.enabled = NO;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    UIImage *capturedImage = [UIImage.alloc initWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
    dispatch_async(dispatch_get_main_queue(), ^{ [self processImage:capturedImage]; });
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
}

- (void)processImage:(UIImage *)image;
{
    CGSize newSize = CGSizeMake(self.pixelation, self.pixelation);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 1);
    
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MAX(aspectWidth, aspectHeight);
    
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), newSize.width, 0);
    CGContextRotateCTM(UIGraphicsGetCurrentContext(), M_PI / 2.f);
    [image drawInRect:scaledImageRect];
    UIImage *scaledImage = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage];
    self.imageView.image = scaledImage;
    if (self.liveControl.selectedSegmentIndex && !self.skView.hidden) {
        ((BoxesScene *)self.skView.scene).image = scaledImage;
    }
}

@end
