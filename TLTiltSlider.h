//
//  TLTiltSlider.h
//
//  Created by Ash Furrow on 2013-03-08.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Subclass of UISlider to mimic the bahviour of the iOS 6 music
/// app's volume slider (it has a gradient that moves with the
/// orientation of the device).
///
/// Roll determines the positions of the angular gradient while pitch
/// rotates the entire gradient in place. Adjusts to interface
/// orientation of the status bar. 
@interface TLTiltSlider : UISlider

/// Whether or not changing the tilt animation is active.
///
/// `YES` by default. Useful to disable if this is adversly affecting
/// screen refresh rates on older devices.
@property (nonatomic, assign, getter = tiltIsEnabled) BOOL tiltEnabled;

@end
