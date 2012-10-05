//
//  NewLogViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "NewLogViewController.h"

@interface NewLogViewController ()

@end

@implementation NewLogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Functions

- (void)sliderChanged:(QFloatElement *)slider
{
    CGFloat inrVal = 1.0 + slider.floatValue * 2.0;
    NSString *val = [NSString stringWithFormat:@"%.1f", inrVal];
    QLabelElement *label = (QLabelElement *)[self.root elementWithKey:@"value"];
    [label setValue:val];
}


@end
