TLTiltSlider
============

`TLTiltSlider` is a `UISlider` subclass with an angular gradient for a Thumb image which adjusts its appearance based on the positional attitude of the device. The movement of the gradient when re-orientating the device is subtle. This mimics the iOS 6 Music app (notice the gradient on the sliders).

This class demonstrates how to use the [Core Motion](http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CoreMotion_Reference/_index.html) framework to adjust to device attitude changes. Rendering angular gradients is complex and it may affect your application's responsiveness on older devices. Always make sure to test your application on an actual device. 

![One angular gradient](https://github.com/TeehanLax/TLTiltSlider/raw/master/images/left.png)
![Another angular gradient](https://github.com/TeehanLax/TLTiltSlider/raw/master/images/right.png)

How to Use
------------

Drag `TLTiltSlider.h` and `TLTiltSlider.m`, as well as the images in the `Resources` directory, into your project. Make sure to [link against](http://stackoverflow.com/questions/3352664/how-to-add-existing-frameworks-in-xcode-4) the Core Motion framework. 

Alternatively, you can use [CocoaPods](http://cocoapods.org):

    pod search TLTiltSlider

Create an instance of `TLTiltSlider` and add it to a view hierarchy. The `UISlider` superclass will centre itself vertically within the view; optimal sizes are 23pt or greater. 

    TLTiltHighlightView *slider = [[TLTiltSlider alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 23)];
    [self.view addSubview:slider];

![Slider](https://github.com/TeehanLax/TLTiltSlider/raw/master/images/slider.png)

Alternatively to instantiating the class programmatically, you can also use Interface Builder by selecting the Identity Inspector and changing the class of a view.

![Identity Inspector](https://github.com/TeehanLax/TLTiltSlider/raw/master/images/identityInspector.png)

You can also disable the tilt updates for older devices:

    slider.tiltEnabled = NO;

Requirements
------------

You must link with Core Motion. This project requires ARC.
