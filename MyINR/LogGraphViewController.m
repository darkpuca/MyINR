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
    NSMutableArray *_inrValues, *_minValues, *_maxValues, *_dateValues;
}

- (void)buildGraphData;
- (void)initGraphView;

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
    
    _inrValues = [[NSMutableArray alloc] init];
    _minValues = [[NSMutableArray alloc] init];
    _maxValues = [[NSMutableArray alloc] init];
    _dateValues = [[NSMutableArray alloc] init];
    [self buildGraphData];

//    NSLog(@"view rect: %@", NSStringFromCGRect(self.view.bounds));

    [self initGraphView];
    
    
    
    
    
    
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






#pragma mark - Private Functions

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
    [plotSpace setDelegate:self];
    
    // create & init plot
    _inrPlot = [[CPTScatterPlot alloc] init];
    [_inrPlot setIdentifier:@"inr"];
    [_inrPlot setDataSource:self];
    
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
    [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(6)]];
    [plotSpace setGlobalXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt([_inrValues count])]];
    
    CPTMutablePlotRange *yRange = [[CPTMutablePlotRange alloc] initWithLocation:CPTDecimalFromCGFloat(0.0f)
                                                                         length:CPTDecimalFromCGFloat(3.5f)];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    [plotSpace setYRange:yRange];
    [plotSpace setGlobalYRange:yRange];
    
    // configure lines
    CPTMutableLineStyle *inrLineStyle = [[CPTMutableLineStyle alloc] init];
    [inrLineStyle setLineColor:[[CPTColor redColor] colorWithAlphaComponent:0.8f]];
    [inrLineStyle setLineWidth:6.0f];
    [_inrPlot setDataLineStyle:inrLineStyle];
    
    CPTMutableLineStyle *inrSymbolLineStyle = [[CPTMutableLineStyle alloc] init];
    [inrSymbolLineStyle setLineColor:inrLineStyle.lineColor];
    CPTPlotSymbol *inrSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    [inrSymbol setFill:[CPTFill fillWithColor:[CPTColor redColor]]];
    [inrSymbol setLineStyle:inrSymbolLineStyle];
    [inrSymbol setSize:CGSizeMake(8.0f, 8.0f)];
    [_inrPlot setPlotSymbol:inrSymbol];
    
    CPTMutableLineStyle *minLineStyle = [[CPTMutableLineStyle alloc] init];
    [minLineStyle setLineColor:[[CPTColor yellowColor] colorWithAlphaComponent:0.6f]];
    [minLineStyle setLineWidth:2.0f];
    [_minPlot setDataLineStyle:minLineStyle];
    
    CPTMutableLineStyle *maxLineStyle = [[CPTMutableLineStyle alloc] init];
    [maxLineStyle setLineColor:[[CPTColor yellowColor] colorWithAlphaComponent:0.6f]];
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
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    [gridLineStyle setLineColor:[CPTColor darkGrayColor]];
    [gridLineStyle setLineWidth:1.0f];
    
    // configure axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *axisX = axisSet.xAxis;
    [axisX setTitle:@"Check date"];
    [axisX setTitleTextStyle:axisTitleStyle];
    [axisX setTitleOffset:16.0f];
    [axisX setLabelTextStyle:axisTextStyle];
    [axisX setLabelingPolicy:CPTAxisLabelingPolicyNone];
    [axisX setMajorTickLineStyle:axisLineStyle];
    [axisX setMajorTickLength:4.0f];
    [axisX setTickDirection:CPTSignNegative];
    [axisX setAxisLineStyle:axisLineStyle];

    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:[_dateValues count]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[_dateValues count]];
    
    for (int i = 0; i < [_dateValues count]; i++)
    {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[_dateValues objectAtIndex:i] textStyle:axisTextStyle];
        float location = (float)i;
        [label setTickLocation:CPTDecimalFromFloat(location)];
        [label setOffset:axisX.majorTickLength];
        [xLabels addObject:label];
        [xLocations addObject:[NSNumber numberWithFloat:location]];
    }
    
    [axisX setAxisLabels:xLabels];
    [axisX setMajorTickLocations:xLocations];
//    [axisX setAxisConstraints:[CPTConstraints constraintWithLowerOffset:0.0f]];
    
    CPTXYAxis *axisY = axisSet.yAxis;
    [axisY setTitle:@"INR"];
    [axisY setTitleTextStyle:axisTitleStyle];
    [axisY setTitleOffset:-40.0f];
    [axisY setLabelTextStyle:axisTextStyle];
    [axisY setLabelingPolicy:CPTAxisLabelingPolicyNone];
    [axisY setLabelOffset:16.0f];
    [axisY setMajorTickLineStyle:axisLineStyle];
    [axisY setMajorTickLength:4.0f];
    [axisY setMinorTickLineStyle:axisLineStyle];
    [axisY setMinorTickLength:2.0f];
    [axisY setTickDirection:CPTSignPositive];
    [axisY setMajorGridLineStyle:gridLineStyle];
    
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


#pragma mark - Public Functions




@end
