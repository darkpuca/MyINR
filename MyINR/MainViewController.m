//
//  MainViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "MainViewController.h"
#import "NewLogViewController.h"
#import "LogViewController.h"
#import "SettingViewController.h"


@interface MainViewController ()

- (QRootElement *)createNewLogRoot;

@end

@implementation MainViewController

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

    UIBarButtonItem *newBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newButtonPressed)];
    UIBarButtonItem *logBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(logButtonPressed)];
    [self.navigationItem setRightBarButtonItem:newBarButton];
    [self.navigationItem setLeftBarButtonItem:logBarButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Private Functions

- (QRootElement *)createNewLogRoot
{
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    root.title = @"New Record";
    
    QSection *dateSection = [[QSection alloc] initWithTitle:@"Date"];
    QDateTimeInlineElement *dateElmt = [[QDateTimeInlineElement alloc] initWithTitle:@"Check date" date:[NSDate date]];
    dateElmt.mode = UIDatePickerModeDate;
    dateElmt.key = @"date";
    [dateSection addElement:dateElmt];
    
    QSection *inrSection = [[QSection alloc] initWithTitle:@"INR"];
    QLabelElement *valueElmt = [[QLabelElement alloc] initWithTitle:@"INR 검사수치" Value:@"2.0"];
    valueElmt.key = @"value";
    [inrSection addElement:valueElmt];
    QFloatElement *sliderElmt = [[QFloatElement alloc] initWithValue:0.5f];
    sliderElmt.key = @"slider";
    sliderElmt.controllerAction = @"sliderChanged:";
    [inrSection addElement:sliderElmt];
    
    [root addSection:dateSection];
    [root addSection:inrSection];
    
    return root;
}




#pragma mark - Public Functions

- (void)logButtonPressed
{
    
    
}

- (void)newButtonPressed
{
    QRootElement *root = [self createNewLogRoot];
    
    NewLogViewController *viewController = [[NewLogViewController alloc] initWithRoot:root];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)settingButtonPressed
{
    
}



@end
