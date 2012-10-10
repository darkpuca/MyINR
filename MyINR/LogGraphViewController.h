//
//  LogGraphViewController.h
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@interface LogGraphViewController : UIViewController <CPTPlotDataSource, CPTScatterPlotDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;


- (void)showYearActionSheet;

@end
