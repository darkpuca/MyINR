//
//  LogViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "LogViewController.h"
#import "LogTableViewController.h"
#import "LogGraphViewController.h"

@interface LogViewController ()
{
    LogTableViewController *_tableViewController;
    LogGraphViewController *_graphViewController;
}

- (void)backPressed;

@end

@implementation LogViewController

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
    [self setTitle:@"INR History"];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backPressed)];
    
    [self.navigationItem setLeftBarButtonItem:backBarButton];

    if (nil == _tableViewController)
        _tableViewController = [[LogTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [_tableViewController.view setFrame:self.view.bounds];
    [self.view addSubview:_tableViewController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
    {
        if (nil == _tableViewController)
            _tableViewController = [[LogTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        [_tableViewController.view setFrame:self.view.bounds];
        [_tableViewController.view setAlpha:0.0f];
        [self.view addSubview:_tableViewController.view];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [_tableViewController.view setAlpha:1.0f];
                         } completion:^(BOOL finished) {
                             if (_graphViewController)
                                 [_graphViewController.view removeFromSuperview];
                         }];
    }
    else
    {
        if (nil == _graphViewController)
            _graphViewController = [[LogGraphViewController alloc] initWithNibName:@"LogGraphViewController" bundle:nil];
        
        [_graphViewController.view setFrame:self.view.bounds];
        [_graphViewController.view setAlpha:0.0f];
        [self.view addSubview:_graphViewController.view];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [_graphViewController.view setAlpha:1.0f];
                         } completion:^(BOOL finished) {
                             if (_tableViewController)
                                 [_tableViewController.view removeFromSuperview];
                         }];
    }

}



#pragma mark - Private Functions

- (void)backPressed
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
