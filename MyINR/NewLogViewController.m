//
//  NewLogViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "NewLogViewController.h"
#import "AppDelegate.h"

@interface NewLogViewController ()

- (void)sliderChanged:(UISlider *)sender;
- (void)registPressed:(id)sender;

@end

@implementation NewLogViewController

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



#pragma mark - Functions

- (void)sliderChanged:(UISlider *)sender;
{
    CGFloat inrVal = 1.0 + sender.value * 2.0;
    NSString *val = [NSString stringWithFormat:@"%.1f", inrVal];

    QLabelElement *label = (QLabelElement *)[self.root elementWithKey:@"value"];

    [label setValue:val];
    [self.quickDialogTableView reloadCellForElements:label, nil];
}

- (void)registPressed:(id)sender
{
    QDateTimeElement *dateElmt = (QDateTimeElement *)[self.root elementWithKey:@"date"];
    QLabelElement *valueElmt = (QLabelElement *)[self.root elementWithKey:@"value"];
    QEntryElement *memoElmt = (QEntryElement *)[self.root elementWithKey:@"memo"];
    
    NSMutableDictionary *newInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    [newInfo setValue:dateElmt.dateValue forKey:@"date"];
    [newInfo setValue:[NSNumber numberWithFloat:[[valueElmt value] floatValue]] forKey:@"inr"];
    [newInfo setValue:memoElmt.textValue forKey:@"memo"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate insertNewData:newInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    NSLog(@"date: %@, inr: %@, memo: %@", dateElmt.dateValue, valueElmt.value, memoElmt.textValue);
}


@end
