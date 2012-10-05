//
//  MainViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "NewLogViewController.h"
#import "LogViewController.h"
#import "SettingViewController.h"


@interface MainViewController ()

- (QRootElement *)createNewLogRoot;
- (QRootElement *)createSettingRoot;

@end



@implementation MainViewController

@synthesize nameLabel = _nameLabel, dateLabel = _dateLabel, inrLabel = _inrLabel, addonLabel = _addonLabel, minLabel = _minLabel, maxLabel = _maxLabel;

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
    
    [self setTitle:@"My INR"];

    UIBarButtonItem *newBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newButtonPressed)];
    UIBarButtonItem *logBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(logButtonPressed)];
    [self.navigationItem setRightBarButtonItem:newBarButton];
    [self.navigationItem setLeftBarButtonItem:logBarButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    _nameLabel = nil;
    _dateLabel = nil;
    _inrLabel = nil;
    _addonLabel = nil;
    _minLabel = nil;
    _maxLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLastLog];
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
    QLabelElement *valueElmt = [[QLabelElement alloc] initWithTitle:@"검사수치" Value:@"2.0"];
    valueElmt.key = @"value";
    [inrSection addElement:valueElmt];
    QFloatElement *sliderElmt = [[QFloatElement alloc] initWithValue:0.5f];
    sliderElmt.key = @"slider";
    sliderElmt.sliderAction = @"sliderChanged:";
    [inrSection addElement:sliderElmt];
    
    QSection *memoSection = [[QSection alloc] init];
    QEntryElement *memoElmt = [[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:@"memo"];
    memoElmt.key = @"memo";
    [memoSection addElement:memoElmt];
    
    QSection *btnSection = [[QSection alloc] init];
    QButtonElement *buttonElmt = [[QButtonElement alloc] initWithTitle:@"Registration"];
    buttonElmt.controllerAction = @"registPressed:";
    [btnSection addElement:buttonElmt];
    
    [root addSection:dateSection];
    [root addSection:inrSection];
    [root addSection:memoSection];
    [root addSection:btnSection];
    
    return root;
}

- (QRootElement *)createSettingRoot
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    root.title = @"Settings";
    
    NSString *username = [appDelegate.settings valueForKey:@"name"];
    if ([username isEqualToString:@"User"]) username = nil;
    
    QSection *userSection = [[QSection alloc] initWithTitle:@"User"];
    QEntryElement *nameElmt = [[QEntryElement alloc] initWithTitle:@"Name" Value:username Placeholder:@"Enter your name"];
    nameElmt.key = @"name";
    [userSection addElement:nameElmt];

    NSMutableArray *valItems = [[NSMutableArray alloc] init];
    for (CGFloat val = 1.0; val <= 3.0; val += 0.1)
    {
        NSString *itemVal = [NSString stringWithFormat:@"%.1f", val];
        [valItems addObject:itemVal];
    }
    
    QSection *inrSection = [[QSection alloc] init];
    [inrSection setTitle:@"INR"];
    [inrSection setFooter:@"담당 주치의에게 권고 받은 적정 INR을 설정해주세요."];
    QPickerElement *targetElmt = [[QPickerElement alloc] initWithTitle:@"목표 INR"
                                                                 items:[NSArray arrayWithObject:valItems]
                                                                 value:[appDelegate.settings valueForKey:@"target"]];
    targetElmt.key = @"target";
    [inrSection addElement:targetElmt];
    QPickerElement *minElmt = [[QPickerElement alloc] initWithTitle:@"적정 변동폭 최저"
                                                              items:[NSArray arrayWithObject:valItems]
                                                              value:[appDelegate.settings valueForKey:@"min"]];
    minElmt.key = @"min";
    [inrSection addElement:minElmt];
    QPickerElement *maxElmt = [[QPickerElement alloc] initWithTitle:@"적정 변동폭 최고"
                                                              items:[NSArray arrayWithObject:valItems]
                                                              value:[appDelegate.settings valueForKey:@"max"]];
    maxElmt.key = @"max";
    [inrSection addElement:maxElmt];
    
    QSection *btnSection = [[QSection alloc] init];
    QButtonElement *buttonElmt = [[QButtonElement alloc] initWithTitle:@"Save settings"];
    buttonElmt.controllerAction = @"savePressed:";
    [btnSection addElement:buttonElmt];
    
    [root addSection:userSection];
    [root addSection:inrSection];
    [root addSection:btnSection];
    
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
    QRootElement *root = [self createSettingRoot];
    SettingViewController *viewController = [[SettingViewController alloc] initWithRoot:root];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)updateLastLog
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [_nameLabel setText:[appDelegate.settings valueForKey:@"name"]];
    [_minLabel setText:[appDelegate.settings valueForKey:@"min"]];
    [_maxLabel setText:[appDelegate.settings valueForKey:@"max"]];
    
    NSString *logSql = @"SELECT * FROM INR_LOG ORDER BY CHECK_DATE DESC LIMIT 2";
    FMResultSet *rs = [appDelegate.inrDB executeQuery:logSql];
    
    NSInteger count = 0;
    [_addonLabel setHidden:YES];
    
    while ([rs next])
    {
        count++;
        
        if (1 == count)
        {
            [_dateLabel setText:[rs stringForColumn:@"CHECK_DATE"]];
            
            NSString *inrString = [rs stringForColumn:@"INR"];
            
            CGFloat inr = [inrString floatValue];
            CGFloat min = [[appDelegate.settings valueForKey:@"min"] floatValue];
            CGFloat max = [[appDelegate.settings valueForKey:@"max"] floatValue];
            CGFloat target = [[appDelegate.settings valueForKey:@"target"] floatValue];
            
            [_inrLabel setText:inrString];
            
            if (min <= inr && max >= inr)
            {
                [_inrLabel setTextColor:[UIColor blueColor]];
                if (target == inr)
                    [_inrLabel setFont:[UIFont boldSystemFontOfSize:32.0f]];
                else
                    [_inrLabel setFont:[UIFont boldSystemFontOfSize:28.0f]];
            }
            else
            {
                [_inrLabel setTextColor:[UIColor redColor]];
            }
            
        }
        else
        {
            [_addonLabel setHidden:NO];
            NSString *otherInrString = [rs stringForColumn:@"INR"];
            CGFloat inr = [[_inrLabel text] floatValue];
            CGFloat otherInr = [otherInrString floatValue];
            NSString *addonMsg;
            if (inr > otherInr)
                addonMsg = [NSString stringWithFormat:@"이전 대비 +%.1f", (inr - otherInr)];
            else if (inr < otherInr)
                addonMsg = [NSString stringWithFormat:@"이전 대비 -%.1f", (otherInr - inr)];
            else if (inr == otherInr)
                addonMsg = @"이전과 동일";
            [_addonLabel setText:addonMsg];
        }
    }
    
    if (0 == count)
    {
        [_dateLabel setText:@"None"];
        [_inrLabel setText:@"None"];
        [_inrLabel setTextColor:[UIColor blackColor]];
        [_addonLabel setHidden:YES];
    }
    
}



@end
