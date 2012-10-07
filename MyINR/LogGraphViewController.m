//
//  LogGraphViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "LogGraphViewController.h"
#import "AppDelegate.h"
#import "CPTGraph.h"


enum kGraphPlotTypes
{
    kGraphPlotMin,
    kGraphPlotMax,
    kGraphPlotINR,
    kGraphPlotCount
};


@interface LogGraphViewController ()
{
    S7GraphView *_graphView;
    NSMutableArray *_inrValues, *_minValues, *_maxValues, *_dateValues;
}

- (void)buildGraphData;

@end


@implementation LogGraphViewController

@synthesize scrollView = _scrollView;


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

    _graphView = [[S7GraphView alloc] initWithFrame:CGRectMake(0, 0, 480, 200)];
    [_graphView setDataSource:self];
    [_graphView setBackgroundColor:[UIColor whiteColor]];
    [_graphView setGridXColor:[UIColor lightGrayColor]];
    [_graphView setGridYColor:[UIColor lightGrayColor]];
    [_graphView setXValuesColor:[UIColor blueColor]];
    [_graphView setYValuesColor:[UIColor orangeColor]];

    
    [_scrollView addSubview:_graphView];
    
    _inrValues = [[NSMutableArray alloc] init];
    _minValues = [[NSMutableArray alloc] init];
    _maxValues = [[NSMutableArray alloc] init];
    _dateValues = [[NSMutableArray alloc] init];
    
    [self buildGraphData];
    
    
    
    [_graphView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    _scrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark S7GraphViewDataSource methods

- (NSUInteger)graphViewNumberOfPlots:(S7GraphView *)graphView
{
    return kGraphPlotCount;
}

- (NSArray *)graphViewXValues:(S7GraphView *)graphView
{
    return _dateValues;
}

- (NSArray *)graphView:(S7GraphView *)graphView yValuesForPlot:(NSUInteger)plotIndex
{
    if (kGraphPlotMin == plotIndex)
        return _minValues;
    else if (kGraphPlotMax == plotIndex)
        return _maxValues;
    else if (kGraphPlotINR == plotIndex)
        return _inrValues;
 
    return nil;
}

- (BOOL)graphView:(S7GraphView *)graphView shouldFillPlot:(NSUInteger)plotIndex
{
    
    return NO;
}


#pragma Private Functions

- (void)buildGraphData
{
    [_inrValues removeAllObjects];
    [_minValues removeAllObjects];
    [_maxValues removeAllObjects];
    [_dateValues removeAllObjects];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *sql = @"SELECT CHECK_DATE, INR FROM INR_LOG ORDER BY CHECK_DATE ASC";
    FMResultSet *rs = [appDelegate.inrDB executeQuery:sql];
    while ([rs next])
    {
        NSString *dateString = [rs stringForColumn:@"CHECK_DATE"];
        NSString *inrString = [rs stringForColumn:@"INR"];
        NSNumber *inr = [NSNumber numberWithFloat:[inrString floatValue]];
        
        [_dateValues addObject:dateString];
        [_inrValues addObject:inr];
    }
    
    NSNumber *min = [NSNumber numberWithFloat:[[appDelegate.settings valueForKey:@"min"] floatValue]];
    NSNumber *max = [NSNumber numberWithFloat:[[appDelegate.settings valueForKey:@"max"] floatValue]];
    
    for (int i = 0; i < [_dateValues count]; i++)
    {
        [_minValues addObject:min];
        [_maxValues addObject:max];
    }
    
}



#pragma Public Functions




@end
