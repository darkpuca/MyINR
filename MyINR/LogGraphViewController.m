//
//  LogGraphViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "LogGraphViewController.h"
#import "AppDelegate.h"


enum kGraphPlotTypes
{
    kGraphPlotMin,
    kGraphPlotMax,
    kGraphPlotINR,
    kGraphPlotCount
};


@interface LogGraphViewController ()
{
    CPTGraphHostingView *_graphHostView;
    CPTGraph *_graph;
    CPTScatterPlot *_inrPlot, *_minPlot, *_maxPlot;
    CPTAnnotation *_inrAnnotation;
    NSMutableArray *_years;
    NSMutableArray *_inrValues, *_minValues, *_maxValues, *_dateValues;
}

- (void)buildYearItems;
- (void)buildGraphData:(NSNumber *)year;
- (void)initGraphView;
- (void)hideAnnotation;

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
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _years = [[NSMutableArray alloc] init];
    [self buildYearItems];
    
    _inrValues = [[NSMutableArray alloc] init];
    _minValues = [[NSMutableArray alloc] init];
    _maxValues = [[NSMutableArray alloc] init];
    _dateValues = [[NSMutableArray alloc] init];
    
    [self initGraphView];

    if ([_years count])
        [self buildGraphData:[_years objectAtIndex:0]];

//    NSLog(@"view rect: %@", NSStringFromCGRect(self.view.bounds));

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



#pragma mark - CPTPlotDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([plot isEqual:_inrPlot])
        return [_inrValues count];
    else if ([plot isEqual:_minPlot])
        return [_minValues count];
    else if ([plot isEqual:_maxPlot])
        return [_maxValues count];
    
    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
//    NSLog(@"%@ plot field: %i, index: %i", plot.identifier, fieldEnum, index);

    if ([plot isEqual:_inrPlot])
    {
        if (CPTScatterPlotFieldX == fieldEnum)
            return [NSNumber numberWithInt:index];
        else if (CPTScatterPlotFieldY == fieldEnum)
            return [_inrValues objectAtIndex:index];
    }
    else if ([plot isEqual:_minPlot])
    {
        if (CPTScatterPlotFieldX == fieldEnum)
            return [NSNumber numberWithInt:index];
        else if (CPTScatterPlotFieldY == fieldEnum)
            return [_minValues objectAtIndex:index];
    }
    else if ([plot isEqual:_maxPlot])
    {
        if (CPTScatterPlotFieldX == fieldEnum)
            return [NSNumber numberWithInt:index];
        else if (CPTScatterPlotFieldY == fieldEnum)
            return [_maxValues objectAtIndex:index];
    }
    
    return [NSDecimalNumber zero];
}


#pragma mark - CPTScatterPlotDelegate methods

- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"plot value: %.1f", [[_inrValues objectAtIndex:index] floatValue]);

    if (_inrAnnotation)
    {
        [_graph.plotAreaFrame.plotArea removeAnnotation:_inrAnnotation];
        _inrAnnotation = nil;
    }
    
    UIFont *annFont = [UIFont boldSystemFontOfSize:24.0f];
    CPTMutableTextStyle *annTextStyle = [CPTMutableTextStyle textStyle];
    [annTextStyle setColor:[CPTColor whiteColor]];
    [annTextStyle setFontName:annFont.fontName];
    [annTextStyle setFontSize:annFont.pointSize];

    NSNumber *x = [NSNumber numberWithInt:index];
    NSNumber *y = [_inrValues objectAtIndex:index];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    _inrAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:_graph.defaultPlotSpace
                                                       anchorPlotPoint:anchorPoint];

	NSString *inrValue = [NSString stringWithFormat:@"%.1f", [[_inrValues objectAtIndex:index] floatValue]];
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:inrValue style:annTextStyle];
	_inrAnnotation.contentLayer = textLayer;
    _inrAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [_graph.plotAreaFrame.plotArea addAnnotation:_inrAnnotation];
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex)
    {
        [self refreshByYearIndex:buttonIndex];
    }
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}



#pragma mark - Private Functions

- (void)buildYearItems
{
    [_years removeAllObjects];
    
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
        NSString *yearSql = [NSString stringWithFormat:@"SELECT COUNT(ID) FROM INR_LOG WHERE CHECK_DATE BETWEEN '%i-01-01' AND '%i-12-31' ORDER BY CHECK_DATE DESC, ID DESC", year, year];
        FMResultSet *yearRs = [appDelegate.inrDB executeQuery:yearSql];
        if ([yearRs next])
        {
            NSInteger rsCount = [yearRs intForColumnIndex:0];
            if (rsCount)
                [_years addObject:[NSNumber numberWithInt:year]];
        }
    }
}

- (void)buildGraphData:(NSNumber *)year
{
    [_inrValues removeAllObjects];
    [_minValues removeAllObjects];
    [_maxValues removeAllObjects];
    [_dateValues removeAllObjects];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT CHECK_DATE, INR FROM INR_LOG WHERE CHECK_DATE BETWEEN '%@-01-01' AND '%@-12-31' ORDER BY CHECK_DATE ASC", year, year];
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
    
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:[_dateValues count]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[_dateValues count]];

    // update x-axis range
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[_graph defaultPlotSpace];
    [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(6)]];
    [plotSpace setGlobalXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt([_inrValues count])]];
    
    // update x-axis labels
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *axisX = axisSet.xAxis;
    [axisX setTitle:[NSString stringWithFormat:@"Log of %@", year]];
    
    for (int i = 0; i < [_dateValues count]; i++)
    {
        NSString *dateString = [[_dateValues objectAtIndex:i] substringFromIndex:5];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:dateString textStyle:axisX.labelTextStyle];
        float location = (float)i;
        [label setTickLocation:CPTDecimalFromFloat(location)];
        [label setOffset:axisX.majorTickLength];
        [xLabels addObject:label];
        [xLocations addObject:[NSNumber numberWithFloat:location]];
    }
    
    [axisX setAxisLabels:xLabels];
    [axisX setMajorTickLocations:xLocations];
    [axisX setAxisConstraints:[CPTConstraints constraintWithLowerOffset:0.0f]];

}

- (void)initGraphView
{
    // create & init hosting view
    _graphHostView = [[CPTGraphHostingView alloc] initWithFrame: self.view.bounds];
    [_graphHostView setAllowPinchScaling:NO];
    [self.view addSubview:_graphHostView];
    
    // setup text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setColor:[CPTColor grayColor]];
    UIFont *textFont = [UIFont systemFontOfSize:20.0f];
    [textStyle setFontName:[textFont fontName]];
    [textStyle setFontSize:[textFont pointSize]];
    
    // create & init graph
    _graph = [[CPTXYGraph alloc] initWithFrame:_graphHostView.bounds];
    [_graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
    [_graphHostView setHostedGraph:_graph];
    
    [_graph.plotAreaFrame setPaddingLeft:50.0f];
    [_graph.plotAreaFrame setPaddingBottom:30.0f];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[_graph defaultPlotSpace];
    [plotSpace setAllowsUserInteraction:YES];
    
    // create & init plot
    _inrPlot = [[CPTScatterPlot alloc] init];
    [_inrPlot setIdentifier:@"inr"];
    [_inrPlot setDataSource:self];
    [_inrPlot setDelegate:self];
    
    _minPlot = [[CPTScatterPlot alloc] init];
    [_minPlot setIdentifier:@"min"];
    [_minPlot setDataSource:self];
    
    _maxPlot = [[CPTScatterPlot alloc] init];
    [_maxPlot setIdentifier:@"max"];
    [_maxPlot setDataSource:self];
    
    [_graph addPlot:_minPlot];
    [_graph addPlot:_maxPlot];
    [_graph addPlot:_inrPlot];
    
    // configure ranges
    CPTMutablePlotRange *yRange = [[CPTMutablePlotRange alloc] initWithLocation:CPTDecimalFromCGFloat(0.0f)
                                                                         length:CPTDecimalFromCGFloat(4.0f)];
//    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    [plotSpace setYRange:[[CPTPlotRange alloc] initWithLocation:CPTDecimalFromCGFloat(1.0f) length:CPTDecimalFromCGFloat(2.0f)]];
    [plotSpace setGlobalYRange:yRange];
    
    // configure lines
    CPTMutableLineStyle *inrLineStyle = [[CPTMutableLineStyle alloc] init];
    [inrLineStyle setLineColor:[[CPTColor redColor] colorWithAlphaComponent:0.6f]];
    [inrLineStyle setLineWidth:6.0f];
    [_inrPlot setDataLineStyle:inrLineStyle];
    
    CPTMutableLineStyle *inrSymbolLineStyle = [[CPTMutableLineStyle alloc] init];
    [inrSymbolLineStyle setLineColor:inrLineStyle.lineColor];
    CPTPlotSymbol *inrSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    [inrSymbol setFill:[CPTFill fillWithColor:[CPTColor redColor]]];
    [inrSymbol setLineStyle:inrSymbolLineStyle];
    [inrSymbol setSize:CGSizeMake(18.0f, 18.0f)];
    [_inrPlot setPlotSymbol:inrSymbol];
    
    CPTMutableLineStyle *minLineStyle = [[CPTMutableLineStyle alloc] init];
    [minLineStyle setLineColor:[[CPTColor yellowColor] colorWithAlphaComponent:0.4f]];
    [minLineStyle setLineWidth:2.0f];
    [_minPlot setDataLineStyle:minLineStyle];
    
    CPTMutableLineStyle *maxLineStyle = [[CPTMutableLineStyle alloc] init];
    [maxLineStyle setLineColor:[[CPTColor yellowColor] colorWithAlphaComponent:0.4f]];
    [maxLineStyle setLineWidth:2.0f];
    [_maxPlot setDataLineStyle:maxLineStyle];
    
    // configure axis styles
    UIFont *axisTitleFont = [UIFont boldSystemFontOfSize:14.0f];
    UIFont *axisTextFont = [UIFont systemFontOfSize:11.0f];
    
    CPTMutableTextStyle *axisTitleStyle = [[CPTMutableTextStyle alloc] init];
    [axisTitleStyle setColor:[CPTColor whiteColor]];
    [axisTitleStyle setFontName:axisTitleFont.fontName];
    [axisTitleStyle setFontSize:axisTitleFont.pointSize];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    [axisTextStyle setColor:[CPTColor whiteColor]];
    [axisTextStyle setFontName:axisTextFont.fontName];
    [axisTextStyle setFontSize:axisTextFont.pointSize];
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    [axisLineStyle setLineColor:[CPTColor whiteColor]];
    [axisLineStyle setLineWidth:2.0f];
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    [tickLineStyle setLineColor:[CPTColor whiteColor]];
    [tickLineStyle setLineWidth:2.0f];
    
    // configure axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *axisX = axisSet.xAxis;
    if ([_years count])
        [axisX setTitle:[NSString stringWithFormat:@"Log of %@", [_years objectAtIndex:0]]];
    else
        [axisX setTitle:@"Log"];
        
    [axisX setTitleTextStyle:axisTitleStyle];
    [axisX setTitleOffset:16.0f];
    [axisX setLabelTextStyle:axisTextStyle];
    [axisX setLabelingPolicy:CPTAxisLabelingPolicyNone];
    [axisX setMajorTickLineStyle:axisLineStyle];
    [axisX setMajorTickLength:4.0f];
    [axisX setTickDirection:CPTSignNegative];
    [axisX setAxisLineStyle:axisLineStyle];
    
    CPTXYAxis *axisY = axisSet.yAxis;
    [axisY setTitle:@"INR"];
    [axisY setTitleTextStyle:axisTitleStyle];
    [axisY setTitleOffset:-40.0f];
    [axisY setLabelTextStyle:axisTextStyle];
    [axisY setLabelingPolicy:CPTAxisLabelingPolicyNone];
    [axisY setLabelOffset:16.0f];
    [axisY setMajorTickLineStyle:axisLineStyle];
    [axisY setMajorTickLength:6.0f];
    [axisY setMinorTickLineStyle:axisLineStyle];
    [axisY setMinorTickLength:4.0f];
    [axisY setTickDirection:CPTSignPositive];
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    
    float majorIncrement = 0.5f, minorIncrement = 0.1f, maxY = 3.5f;
    for (float f = 0.0f; f <= maxY; f += minorIncrement)
    {
        NSInteger val1 = (NSInteger)(f * 10 + 0.01);
        NSInteger val2 = (NSInteger)(majorIncrement * 10);
        if (0 == (val1 % val2))
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1f", f]
                                                           textStyle:axisTextStyle];
            [label setTickLocation:CPTDecimalFromFloat(f)];
            [label setOffset:-axisY.majorTickLength - axisY.labelOffset];
            [yLabels addObject:label];
            [yMajorLocations addObject:[NSNumber numberWithFloat:f]];
        }
        else
        {
            [yMinorLocations addObject:[NSNumber numberWithFloat:f]];
        }
    }

    [axisY setAxisLabels:yLabels];
    [axisY setMajorTickLocations:yMajorLocations];
    [axisY setMinorTickLocations:yMinorLocations];
    axisY.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0f];
}

- (void)hideAnnotation
{
    if ((_graph.plotAreaFrame.plotArea) && (_inrAnnotation))
    {
        [_graph.plotAreaFrame.plotArea removeAnnotation:_inrAnnotation];
        _inrAnnotation = nil;
    }
}


#pragma mark - Public Functions

- (void)showYearActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    [actionSheet setDelegate:self];
    [actionSheet setTitle:@"Year"];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    for (int i = 0; i < [_years count]; i++)
        [actionSheet addButtonWithTitle:[[_years objectAtIndex:i] stringValue]];
    
    [actionSheet addButtonWithTitle:@"취소"];
    [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons]-1];
    
    [actionSheet showInView:self.view];
}

- (void)refreshByYearIndex:(NSInteger)yearIndex
{
    if (0 <= yearIndex && [_years count] > yearIndex)
    {
        [self buildGraphData:[_years objectAtIndex:yearIndex]];
        
        [_graph reloadData];
    }
}



@end
