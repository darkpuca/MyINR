//
//  LogTableViewController.h
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogTableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel, *inrLabel, *memoLabel;

@end

@interface LogTableViewController : UITableViewController


- (void)refreshLogs;

@end
