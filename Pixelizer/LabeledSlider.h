
@import UIKit;

@interface LabeledSlider : UISlider

@property (nonatomic) UILabel *label;

- (NSString *)labelText;
- (UIColor *)labelTextColor;

@end
