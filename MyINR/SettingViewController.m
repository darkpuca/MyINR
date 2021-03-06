//
//  SettingViewController.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"


@interface SettingViewController ()

- (void)savePressed:(id)sender;
- (void)sendMailPressed:(id)sender;

@end

@implementation SettingViewController


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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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



#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}




#pragma mark - Functions

- (void)savePressed:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    QEntryElement *nameElmt = (QEntryElement *)[self.root elementWithKey:@"name"];
    QPickerElement *targetElmt = (QPickerElement *)[self.root elementWithKey:@"target"];
    QPickerElement *minElmt = (QPickerElement *)[self.root elementWithKey:@"min"];
    QPickerElement *maxElmt = (QPickerElement *)[self.root elementWithKey:@"max"];
    
    if (nil != nameElmt.textValue) [appDelegate.settings setValue:nameElmt.textValue forKey:@"name"];
    [appDelegate.settings setValue:[NSString stringWithFormat:@"%@", targetElmt.value] forKey:@"target"];
    [appDelegate.settings setValue:[NSString stringWithFormat:@"%@", minElmt.value] forKey:@"min"];
    [appDelegate.settings setValue:[NSString stringWithFormat:@"%@", maxElmt.value] forKey:@"max"];
    
    [appDelegate updateSettings];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendMailPressed:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"메일 전송이 불가능한 기기입니다."
                                                           delegate:nil
                                                  cancelButtonTitle:@"확인"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"MyINR feedback"];
    [picker setToRecipients:[NSArray arrayWithObject:@"darkpuca@gmail.com"]];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSData *sqlData = [NSData dataWithContentsOfFile:[appDelegate databaseFilePath]];
    [picker addAttachmentData:sqlData mimeType:@"application/x-sqlite3" fileName:@"MyINR.sqlite"];
    
    [self presentModalViewController:picker animated:YES];

}


@end
