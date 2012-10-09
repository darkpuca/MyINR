//
//  LogTableViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "LogTableViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"


#define kLogTableCellHeight     80

@implementation LogTableCell

@synthesize dateLabel = _dateLabel, inrLabel = _inrLabel, memoLabel = _memoLabel;



@end











@interface LogTableViewController ()
{
    NSMutableDictionary *_logDict;
}

- (void)buildLogItems;

@end

@implementation LogTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _logDict = [[NSMutableDictionary alloc] init];
    
    [self refreshLogs];
    
    __block LogTableViewController *me = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [me refreshLogs];
    }];
    
    [self.tableView setRowHeight:kLogTableCellHeight];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_logDict count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [_logDict allKeys];
    NSString *key = [keys objectAtIndex:section];
    NSArray *items = [_logDict valueForKey:key];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *years = [_logDict allKeys];
    return [years objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogCell";
    LogTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"CustomCells" owner:self options:nil];
		for (id oneObject in xib)
		{
			if ([oneObject isKindOfClass:[LogTableCell class]])
			{
				cell = (LogTableCell *)oneObject;
				break;
			}
		}
    }
    
    NSArray *keys = [_logDict allKeys];
    NSArray *items = [_logDict valueForKey:[keys objectAtIndex:[indexPath section]]];
    NSDictionary *itemDict = [items objectAtIndex:[indexPath row]];
    
    [cell.dateLabel setText:[itemDict valueForKey:@"date"]];
    [cell.inrLabel setText:[itemDict valueForKey:@"inr"]];
    [cell.memoLabel setText:[itemDict valueForKey:@"memo"]];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (1 == ([indexPath row] % 2)) {
		[cell setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.4]];
	}
	else {
		[cell setBackgroundColor:[UIColor clearColor]];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLogTableCellHeight;
}


#pragma mark - Private Functions

- (void)buildLogItems
{
    [_logDict removeAllObjects];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *sql = @"SELECT CHECK_DATE FROM INR_LOG ORDER BY CHECK_DATE DESC LIMIT 1";
    FMResultSet *rs = [appDelegate.inrDB executeQuery:sql];
    if (![rs next]) return;
    
    NSInteger lastYear = [[[rs stringForColumnIndex:0] substringToIndex:4] intValue];
    
    sql = @"SELECT CHECK_DATE FROM INR_LOG ORDER BY CHECK_DATE ASC LIMIT 1";
    rs = [appDelegate.inrDB executeQuery:sql];
    [rs next];
    
    NSInteger firstYear = [[[rs stringForColumnIndex:0] substringToIndex:4] intValue];
    
    for (NSInteger year = lastYear; year >= firstYear; year--)
    {
        NSString *key = [NSString stringWithFormat:@"%i", year];
        NSMutableArray *yearItems = [_logDict valueForKey:key];
        if (nil == yearItems)
        {
            yearItems = [[NSMutableArray alloc] init];
            [_logDict setValue:yearItems forKey:key];
        }
        
        NSString *yearSql = [NSString stringWithFormat:@"SELECT CHECK_DATE, INR, MEMO FROM INR_LOG WHERE CHECK_DATE BETWEEN '%i-01-01' AND '%i-12-31' ORDER BY CHECK_DATE DESC", year, year];
        FMResultSet *yearRs = [appDelegate.inrDB executeQuery:yearSql];
        while ([yearRs next])
        {
            NSMutableDictionary *yearItem = [[NSMutableDictionary alloc] init];
            [yearItem setValue:[yearRs stringForColumn:@"CHECK_DATE"] forKey:@"date"];
            [yearItem setValue:[yearRs stringForColumn:@"INR"] forKey:@"inr"];
            [yearItem setValue:[yearRs stringForColumn:@"MEMO"] forKey:@"memo"];
            [yearItems addObject:yearItem];
        }
    }
    
    [SVProgressHUD dismiss];
}


#pragma mark - Public Functions

- (void)refreshLogs
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self buildLogItems];
    
    [self.tableView.pullToRefreshView stopAnimating];
    
    [self.tableView reloadData];
}

@end
