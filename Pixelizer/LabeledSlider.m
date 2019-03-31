
#import "LabeledSlider.h"

@implementation LabeledSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    self.label = UILabel.new;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17.f];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:self.label];

    return self;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    [self bringSubviewToFront:self.label];
    self.label.frame = CGRectInset([self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value], 4.f, 0.f);
    self.label.text = self.labelText;
    self.label.textColor = self.labelTextColor;
}

- (NSString *)labelText;
{
    return [NSString stringWithFormat:@"%i", (int)roundf(self.value)];
}

- (UIColor *)labelTextColor;
{
    return UIColor.darkGrayColor;
}

@end
