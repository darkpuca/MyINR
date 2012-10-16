//
//  AboutViewController.h
//  MyINR
//
//  Created by darkpuca on 10/16/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController


@property (nonatomic, strong) IBOutlet UIImageView *profileView;
@property (nonatomic ,strong) IBOutlet UIButton *twitterButton, *facebookButton, *githubButton;


- (IBAction)linkButtonPressed:(id)sender;


@end
