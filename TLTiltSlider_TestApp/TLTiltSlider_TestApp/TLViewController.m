//
//  TLViewController.m
//  TLTiltSlider_TestApp
//
//  Created by Ash Furrow on 2013-03-06.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLViewController.h"

#import "TLTiltSlider.h"

@interface TLViewController ()

@end

@implementation TLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TLTiltSlider *slider = [[TLTiltSlider alloc] initWithFrame:(CGRect){.origin.x = 0, .origin.y = 64, .size.width = CGRectGetWidth(self.view.bounds), .size.height = 23}];
    [slider setValue:0.5f];
    [self.view addSubview:slider];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
