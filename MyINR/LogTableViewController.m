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
#import "LogViewController.h"
#import "NewLogViewController.h"


#define kLogTableCellHeight     80

@implementation LogTableCell

@synthesize dateLabel = _dateLabel, inrLabel = _inrLabel, memoLabel = _memoLabel;



@end











@interface LogTableViewController ()
{
    NSMutableArray *_logYears;
    NSIndexPath *_targetIndexPath;
}

- (void)buildLogItems;
- (QRootElement *)createEditLogRoot:(NSDictionary *)logItemDict;

@end



@implementation LogTableViewController

@synthesize parentController = _parentController;

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
    
    _logYears = [[NSMutableArray alloc] init];
    
    [self addPullToRefreshHandler];
    
    [self.tableView setRowHeight:kLogTableCellHeight];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    [self refreshLogs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    _parentController = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_logYears count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *yearDict = [_logYears objectAtIndex:section];
    NSArray *items = [yearDict valueForKey:@"items"];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *yearDict = [_logYears objectAtIndex:section];
    return [[yearDict valueForKey:@"year"] stringValue];
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
    
    NSDictionary *yearDict = [_logYears objectAtIndex:[indexPath section]];
    NSArray *items = [yearDict valueForKey:@"items"];
    NSDictionary *itemDict = [items objectAtIndex:[indexPath row]];
    
    [cell.dateLabel setText:[itemDict valueForKey:@"date"]];
    [cell.inrLabel setText:[itemDict valueForKey:@"inr"]];
    [cell.memoLabel setText:[itemDict valueForKey:@"memo"]];
    
//    if (tableView.editing)
//        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    else
//        cell.editingAccessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.editing)
    {
        NSDictionary *yearDict = [_logYears objectAtIndex:[indexPath section]];
        NSArray *items = [yearDict valueForKey:@"items"];
        NSDictionary *itemDict = [items objectAtIndex:[indexPath row]];
        
        QRootElement *root = [self createEditLogRoot:itemDict];
        
        NewLogViewController *viewController = [[NewLogViewController alloc] initWithRoot:root];
        [viewController setTargetId:[itemDict valueForKey:@"id"]];
        [_parentController.navigationController pushViewController:viewController animated:YES];
    }
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (1 == ([indexPath row] % 2))
		[cell setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.4]];
	else
		[cell setBackgroundColor:[UIColor clearColor]];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLogTableCellHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"확인"
                                                            message:@"선택한 기록을 삭제하시겠습니까?"
                                                           delegate:self
                                                  cancelButtonTitle:@"취소" otherButtonTitles:@"삭제", nil];
        [alertView show];
        
        _targetIndexPath = [indexPath copy];
    }
}



#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

        NSDictionary *yearDict = [_logYears objectAtIndex:[_targetIndexPath section]];
        NSMutableArray *items = [yearDict valueForKey:@"items"];
        NSDictionary *itemDict = [items objectAtIndex:[_targetIndexPath row]];

        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM INR_LOG WHERE ID=%@", [itemDict valueForKey:@"id"]];
        if ([appDelegate.inrDB executeUpdate:deleteSql])
        {
            [items removeObject:itemDict];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_targetIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }
}


#pragma mark - Private Functions

- (void)buildLogItems
{
    [_logYears removeAllObjects];
    
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
        NSString *countSql = [NSString stringWithFormat:@"SELECT COUNT(ID) FROM INR_LOG WHERE CHECK_DATE BETWEEN '%i-01-01' AND '%i-12-31'", year, year];
        FMResultSet *countRs = [appDelegate.inrDB executeQuery:countSql];
        if ([countRs next])
        {
            NSInteger rsCount = [countRs intForColumnIndex:0];
            if (rsCount)
            {
                NSMutableDictionary *yearDict = [[NSMutableDictionary alloc] init];
                [yearDict setValue:[NSNumber numberWithInt:year] forKey:@"year"];
                NSMutableArray *yearItems =[[NSMutableArray alloc] init];
                [yearDict setValue:yearItems forKey:@"items"];
                [_logYears addObject:yearDict];
                
                NSString *yearSql = [NSString stringWithFormat:@"SELECT ID, CHECK_DATE, INR, MEMO FROM INR_LOG WHERE CHECK_DATE BETWEEN '%i-01-01' AND '%i-12-31' ORDER BY CHECK_DATE DESC, ID DESC", year, year];
                FMResultSet *yearRs = [appDelegate.inrDB executeQuery:yearSql];
                while ([yearRs next])
                {
                    NSMutableDictionary *yearItem = [[NSMutableDictionary alloc] init];
                    [yearItem setValue:[NSNumber numberWithInt:[yearRs intForColumn:@"ID"]] forKey:@"id"];
                    [yearItem setValue:[yearRs stringForColumn:@"CHECK_DATE"] forKey:@"date"];
                    [yearItem setValue:[yearRs stringForColumn:@"INR"] forKey:@"inr"];
                    [yearItem setValue:[yearRs stringForColumn:@"MEMO"] forKey:@"memo"];
                    [yearItems addObject:yearItem];
                }
            }
        }
    }
    
    [SVProgressHUD dismiss];
}

- (QRootElement *)createEditLogRoot:(NSDictionary *)logItemDict
{
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    root.title = @"Edit Record";
    
    QSection *dateSection = [[QSection alloc] initWithTitle:@"Date"];
    QLabelElement *dateElmt = [[QLabelElement alloc] initWithTitle:@"Check date" Value:[logItemDict valueForKey:@"date"]];
    dateElmt.key = @"date";
    [dateSection addElement:dateElmt];
    
    QSection *inrSection = [[QSection alloc] initWithTitle:@"INR"];
    QLabelElement *valueElmt = [[QLabelElement alloc] initWithTitle:@"검사수치" Value:[logItemDict valueForKey:@"inr"]];
    valueElmt.key = @"value";
    [inrSection addElement:valueElmt];
    
    CGFloat inrVal = ([[logItemDict valueForKey:@"inr"] floatValue] - 1.0) / 2.0f;
    QFloatElement *sliderElmt = [[QFloatElement alloc] initWithValue:inrVal];
    sliderElmt.key = @"slider";
    sliderElmt.sliderAction = @"sliderChanged:";
    [inrSection addElement:sliderElmt];
    
    QSection *memoSection = [[QSection alloc] init];
    QEntryElement *memoElmt = [[QEntryElement alloc] initWithTitle:nil Value:[logItemDict valueForKey:@"memo"] Placeholder:@"memo"];
    memoElmt.key = @"memo";
    [memoSection addElement:memoElmt];
    
    QSection *btnSection = [[QSection alloc] init];
    QButtonElement *buttonElmt = [[QButtonElement alloc] initWithTitle:@"Update"];
    buttonElmt.controllerAction = @"updatePressed:";
    [btnSection addElement:buttonElmt];
    
    [root addSection:dateSection];
    [root addSection:inrSection];
    [root addSection:memoSection];
    [root addSection:btnSection];
    
    return root;
}


#pragma mark - Public Functions

- (void)refreshLogs
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self buildLogItems];
    
    [self.tableView.pullToRefreshView stopAnimating];
    
    [self.tableView reloadData];
}

- (void)addPullToRefreshHandler
{
    __block LogTableViewController *me = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [me refreshLogs];
    }];
}

@end
