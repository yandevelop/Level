#import "Tweak.h"

%hook CAMPreviewViewController
%property (nonatomic, strong) UIView *levelIndicator;
%property (nonatomic, strong) CMMotionManager *motManager;
%property (nonatomic, strong) UIImpactFeedbackGenerator *generator;
CGFloat previousRollAngle;
CMAcceleration previousGravity;

- (void)viewDidLoad {
    %orig;

    self.levelIndicator = [[UIView alloc] init];
    self.levelIndicator.backgroundColor = [UIColor whiteColor];
    self.levelIndicator.alpha = 0.8;
    self.levelIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.levelIndicator];

	self.motManager = [[CMMotionManager alloc] init];

	if (self.motManager.isAccelerometerAvailable && self.motManager.isGyroAvailable) {
		self.motManager.deviceMotionUpdateInterval = 0.1;
		[self.motManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
	} else {
		// Handle the case where motion data is not available on the device.
	}

    self.generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self.motManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motionData, NSError *error) {
        if (!error) {
            CMAcceleration gravity = motionData.gravity;
            double rollAccelerometer = atan2(gravity.x, gravity.y) - M_PI;

            // Combine accelerometer and gyroscope data
            CMAcceleration gyroGravity = motionData.gravity;
            double rollGyroscope = atan2(gyroGravity.x, gyroGravity.y) - M_PI;

            // Use a weighted average of accelerometer and gyroscope values
            double weightedRoll = 0.8 * rollAccelerometer + 0.2 * rollGyroscope;

            if (weightedRoll > -0.02 && weightedRoll < 0.02 && !null) {
                [self.generator prepare];
                null = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.generator impactOccurred];
                    [UIView animateWithDuration:0.3 animations:^{
                        self.levelIndicator.alpha = 0.8;
                        self.levelIndicator.backgroundColor = [UIColor greenColor];
                    }];
                });
            } else if (weightedRoll < -0.02 || weightedRoll > 0.02) {
                null = NO;
                if (![self.levelIndicator.backgroundColor isEqual:[UIColor whiteColor]]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.3 animations:^{
                            self.levelIndicator.alpha = 0.2;
                            self.levelIndicator.backgroundColor = [UIColor whiteColor];
                        }];
                    });
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.1 animations:^{
                    self.levelIndicator.transform = CGAffineTransformMakeRotation(weightedRoll);
                }];
            });
        } else {
            NSLog(@"[Level] Error reading motion data: %@", error);
        }
    }];
}

- (void)viewDidLayoutSubviews {
    %orig;

   [NSLayoutConstraint activateConstraints:@[
        [self.levelIndicator.centerXAnchor constraintEqualToAnchor:self.previewView.levelView.centerXAnchor],
        [self.levelIndicator.centerYAnchor constraintEqualToAnchor:self.previewView.levelView.centerYAnchor],
        [self.levelIndicator.widthAnchor constraintEqualToConstant:150],
        [self.levelIndicator.heightAnchor constraintEqualToConstant:1.8]
    ]];
}
%end