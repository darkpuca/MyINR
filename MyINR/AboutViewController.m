//
//  AboutViewController.m
//  MyINR
//
//  Created by darkpuca on 10/16/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AboutViewController.h"

@interface AboutViewController ()

- (void)doneButtonPressed;

@end

@implementation AboutViewController

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

    [self setTitle:@"About MyINR"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]]];

    [_profileView setClipsToBounds:YES];
    [_profileView.layer setCornerRadius:16.0f];
    [_profileView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_profileView.layer setBorderWidth:4.0f];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    [self.navigationItem setRightBarButtonItem:doneBarButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    _profileView = nil;
    _twitterButton = nil;
    _facebookButton = nil;
    _githubButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Private methods

- (void)doneButtonPressed
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Public methods

- (IBAction)linkButtonPressed:(id)sender
{
    NSString *urlString = nil;
    if ([_twitterButton isEqual:sender])
        urlString = @"https://twitter.com/darkpuca";
    else if ([_facebookButton isEqual:sender])
        urlString = @"http://facebook.com/darkpuca";
    else if ([_githubButton isEqual:sender])
        urlString = @"https://github.com/darkpuca/MyINR";
    else
        return;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}


@end
