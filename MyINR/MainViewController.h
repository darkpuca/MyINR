//
//  MainViewController.h
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *nameLabel, *dateLabel, *inrLabel, *addonLabel, *minLabel, *maxLabel;
@property (nonatomic, strong) IBOutlet UIView  *nameView, *dateView;

- (void)logButtonPressed;
- (void)newButtonPressed;

- (void)updateLastLog;

- (IBAction)settingButtonPressed;

@end
