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
#import "SVPullToRefresh.h"

@interface LogViewController ()
{
    LogTableViewController *_tableViewController;
    LogGraphViewController *_graphViewController;
    
    UIBarButtonItem *_editBarButton, *_doneBarButton, *_yearBarButton;
}

- (void)backPressed;
- (void)editPressed;
- (void)donePressed;
- (void)yearPressed;


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
    [self setTitle:@"History"];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed)];
    
    _editBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed)];
    _doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
    _yearBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Year" style:UIBarButtonItemStyleDone target:self action:@selector(yearPressed)];
    
    [self.navigationItem setLeftBarButtonItem:backBarButton];
    [self.navigationItem setRightBarButtonItem:_editBarButton];

    if (nil == _tableViewController)
        _tableViewController = [[LogTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [_tableViewController setParentController:self];
    [_tableViewController.view setFrame:self.view.bounds];
    
    [self.view addSubview:_tableViewController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
    {
        if (_tableViewController)
        {
            [_tableViewController refreshLogs];
        }
    }
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
        
        [_tableViewController addPullToRefreshHandler];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [_tableViewController.view setAlpha:1.0f];
                         } completion:^(BOOL finished) {
                             if (_graphViewController)
                                 [_graphViewController.view removeFromSuperview];
                         }];
        
        if (_tableViewController.tableView.editing)
            [self.navigationItem setRightBarButtonItem:_doneBarButton];
        else
            [self.navigationItem setRightBarButtonItem:_editBarButton];
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
        
        [self.navigationItem setRightBarButtonItem:_yearBarButton];
    }

}



#pragma mark - Private Functions

- (void)backPressed
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)editPressed
{
    if (_tableViewController)
    {
        [_tableViewController.tableView setEditing:YES animated:YES];

        [self.navigationItem setRightBarButtonItem:_doneBarButton];
    }
}

- (void)donePressed
{
    if (_tableViewController)
    {
        [_tableViewController.tableView setEditing:NO animated:YES];
        
        [self.navigationItem setRightBarButtonItem:_editBarButton];
    }
}

- (void)yearPressed
{
    
}



@end
