//
//  TLTiltSlider.m
//
//  Created by Ash Furrow on 2013-03-08.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

#import "TLTiltSlider.h"

@interface TLTiltSlider ()

// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation TLTiltSlider

// This is the rendered size of the entire knob, including the shadow.
static const CGSize kKnobSize = (CGSize){.width = 24, .height = 24};
// This is the margin around kKnobSize which the shadow occupies.
static const CGFloat kShadowMargin = 1.0f;

// Allows support for using instances loaded from nibs or storyboards.
-(id)initWithCoder:(NSCoder *)aCoder
{
    if (!(self = [super initWithCoder:aCoder])) return nil;
    
    [self setup];
    
    return self;
}

// Allows support for using instances instantiated programatically.
- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self setup];
    
    return self;
}

#pragma mark - Private Methods

// Set up the background images and motion detection.
-(void)setup
{
    [self setMinimumTrackImage:[[UIImage imageNamed:@"higlightedBarBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)] forState:UIControlStateNormal];
    [self setMaximumTrackImage:[[UIImage imageNamed:@"trackBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)] forState:UIControlStateNormal];

    // Set up our motion updates
    [self setupMotionDetection];
}

// Creates the device motion manager and starts it updating
// Make sure to only call once.
-(void)setupMotionDetection
{
    NSAssert(self.motionManager == nil, @"Motion manager being set up more than once.");

	// Since tilt is enabled by default, we need to set this ivar explicitly
	_tiltEnabled = YES;

    // Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
    self.motionManager = [[CMMotionManager alloc] init];
    
    [self startDeviceMotionUpdates];
    
    // Need to call once for the initial load
    
    [self updateButtonImageForRoll:0 pitch:0];
}

// Starts the motionManager updating device motions.
-(void)startDeviceMotionUpdates
{
    __weak __typeof(self) weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (error)
        {
            [weakSelf.motionManager stopDeviceMotionUpdates];
            return;
        }
        
        [weakSelf deviceMotionDidUpdate:motion];
    }];
}

// Uppdates the Thumb (knob) image for the given roll and pitch
-(void)updateButtonImageForRoll:(CGFloat)roll pitch:(CGFloat)pitch
{
    // Create an image context big enough for the knob and shadow, and with the main screen's scale
    UIGraphicsBeginImageContextWithOptions(kKnobSize, NO, [[UIScreen mainScreen] scale]);
    
    // We don't need alpha for the image – we'll clip it later.
    // Create a colour space for us to draw the angular gradient.
    CGImageAlphaInfo alphaInfo = kCGImageAlphaNone;
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
    size_t components = CGColorSpaceGetNumberOfComponents(colourSpace);
    size_t bitsPerComponent = 8;
    size_t bytesPerComponent = bitsPerComponent / 8;
    size_t bytesPerRow = kKnobSize.width * bytesPerComponent * components;
    size_t dataLength = bytesPerRow * kKnobSize.height;
    
    uint8_t data[dataLength];
    
    // Create an image context within which we'll render the gradient.
    CGContextRef imageContext = CGBitmapContextCreate(&data, kKnobSize.width, kKnobSize.height, bitsPerComponent, bytesPerRow, colourSpace, alphaInfo);
    
    // This math is borrowed from http://stackoverflow.com/questions/6905466/cgcontextdrawanglegradient
    // Basically, for each pixel, it calculates the grey value of that pixel.
    NSUInteger offset = 0;
    for (NSUInteger y = 0; y < kKnobSize.height; ++y) {
        for (NSUInteger x = 0; x < bytesPerRow; x += components) {
            CGFloat opposite = y - kKnobSize.height/2.;
            CGFloat adjacent = x - kKnobSize.width/2.;
            if (adjacent == 0) adjacent = 0.001; // avoid division by zero
            CGFloat angle = atan(opposite/adjacent);
            // We want value to have a range from [1.5 ... 2.0].
            CGFloat value = 1.5f + 0.5f * cos(2*roll);
            //data[offset] will have a range of [127 ... 255].
            data[offset] = abs(cos((angle * value + 2*pitch)) * 128) + 127;
            
            CGFloat a = (opposite+0.5);
            CGFloat b = (adjacent+0.5);
            
            CGFloat distance = sqrtf(a*a + b*b);
            NSUInteger roundedDistance = lrintf(distance);
            
            if (roundedDistance % 2 == 0)
            {
                data[offset] -= 20 * fabsf(roundedDistance - distance);
            }
            
            offset += components * bytesPerComponent;
        }
    }
    
    // We'll create our image from the context, then release the context and colour space
    CGImageRef image = CGBitmapContextCreateImage(imageContext);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(colourSpace);
    
    // Next, we'll grab the context into a local variable to do our clipping. 
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw a shadow first, under the button.
    {
        CGContextSaveGState(context);
        
        CGRect shadowRect = (CGRect){.origin.x = kShadowMargin, .origin.y = kShadowMargin*2.0f, .size.width = kKnobSize.width - kShadowMargin*2.0, .size.height = kKnobSize.height - kShadowMargin*2.0f};
        CGContextAddEllipseInRect(context, shadowRect);
        CGContextClip(context);
        [[UIColor colorWithWhite:0.0f alpha:0.3f] set];
        CGContextFillRect(context, shadowRect);
        
        CGContextRestoreGState(context);
    }
    
    CGRect knobRect = (CGRect){.origin.x = kShadowMargin, .origin.y = kShadowMargin, .size.width = kKnobSize.width - kShadowMargin*2.0, .size.height = kKnobSize.height - kShadowMargin*2.0f};
    // Clip to a circle
    CGContextAddEllipseInRect(context, knobRect);
    CGContextClip(context);
    
    // Draw our CGImageRef into our context and then release it.
    CGContextDrawImage(context, knobRect, image);
    CGImageRelease(image);
    
    // Grab the image from our context and set it to our applicable control states. 
    UIImage *knobImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbImage:knobImage forState:UIControlStateNormal];
    [self setThumbImage:knobImage forState:UIControlStateSelected];
    [self setThumbImage:knobImage forState:UIControlStateHighlighted];
    
    // End the image context we created at the very beginning of this method. 
    UIGraphicsEndImageContext();
}

#pragma mark - Overridden Properties

// Updates the ivar disables (or enables) the motion manager
-(void)setTiltEnabled:(BOOL)tiltEnabled
{
    _tiltEnabled = tiltEnabled;
    
    if (tiltEnabled && ![self.motionManager isDeviceMotionActive])
    {
        [self startDeviceMotionUpdates];
    }
    else if (!tiltEnabled && [self.motionManager isDeviceMotionActive])
    {
        [self.motionManager stopDeviceMotionUpdates];
    }
}

#pragma mark - Core Motion Methods

-(void)deviceMotionDidUpdate:(CMDeviceMotion *)deviceMotion
{
    // Called when the deviceMotion property of our CMMotionManger updates.
    // Recalculates the gradient locations.
    
    // We need to account for the interface's orientation when calculating the relative roll.
    CGFloat roll = 0.0f;
    CGFloat pitch = 0.0f;
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
            roll = deviceMotion.attitude.roll;
            pitch = deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            roll = -deviceMotion.attitude.roll;
            pitch = -deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            roll = -deviceMotion.attitude.pitch;
            pitch = -deviceMotion.attitude.roll;
            break;
        case UIInterfaceOrientationLandscapeRight:
            roll = deviceMotion.attitude.pitch;
            pitch = deviceMotion.attitude.roll;
            break;
    }
    
    // Update the image with the calculated values. 
    [self updateButtonImageForRoll:roll pitch:pitch];
}

@end
