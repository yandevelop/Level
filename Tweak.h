#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

BOOL null;

@interface CAMLevelIndicatorView : UIView
@end

@interface CAMPreviewView : UIView
@property (nonatomic, strong) CAMLevelIndicatorView *levelView;
@end

@interface CAMPreviewViewController : UIViewController
@property (nonatomic, strong) UIView *levelIndicator;
@property (nonatomic, strong) CMMotionManager *motManager;
@property (nonatomic, strong) UIImpactFeedbackGenerator *generator;
@property (nonatomic, strong) CAMPreviewView *previewView;
@end