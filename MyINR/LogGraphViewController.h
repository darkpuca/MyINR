//
//  LogGraphViewController.h
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "S7GraphView.h"


@interface LogGraphViewController : UIViewController <S7GraphViewDataSource>


@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end
