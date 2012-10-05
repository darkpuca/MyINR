//
//  AppDelegate.m
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"


#define kDatabaseFileName        @"MyINR.sqlite"


@implementation AppDelegate

@synthesize inrDB = _inrDB, settings = _settings;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL isDbInitailized = NO;
    NSString *databasePath = [self databaseFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath])
    {
        NSString *originFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@", kDatabaseFileName];
        [[NSFileManager defaultManager] copyItemAtPath:originFile toPath:databasePath error:nil];
        
        isDbInitailized = YES;
    }
    
    _inrDB = [FMDatabase databaseWithPath:[self databaseFilePath]];
    if (![_inrDB open])
        NSLog(@"db open error");
    
    _settings = [[NSMutableDictionary alloc] init];
    if (isDbInitailized)
    {
        NSString *defaultSql = @"INSERT INTO SETTING (USERNAME, INR_TARGET, INR_MIN, INR_MAX) VALUES ('User', 2.0, 1.0, 3.0)";
        [_inrDB executeUpdate:defaultSql];
        
        [_settings setValue:@"User" forKey:@"name"];
        [_settings setValue:@"2.0" forKey:@"target"];
        [_settings setValue:@"1.0" forKey:@"min"];
        [_settings setValue:@"3.0" forKey:@"max"];
    }
    else
    {
        NSString *sql = @"SELECT * FROM SETTING";
        FMResultSet *rs = [_inrDB executeQuery:sql];
        [rs next];
        
        [_settings setValue:[rs stringForColumn:@"USERNAME"] forKey:@"name"];
        [_settings setValue:[rs stringForColumn:@"INR_TARGET"] forKey:@"target"];
        [_settings setValue:[rs stringForColumn:@"INR_MIN"] forKey:@"min"];
        [_settings setValue:[rs stringForColumn:@"INR_MAX"] forKey:@"max"];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    _naviController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
//    [_naviController.navigationBar setTintColor:[UIColor orangeColor]];
    [self.window addSubview:_naviController.view];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark - Functions

- (NSString *)databaseFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kDatabaseFileName];
}

- (BOOL)insertNewData:(NSDictionary *)info
{
    if (nil == info) return NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateVal = [dateFormatter stringFromDate:[info valueForKey:@"date"]];
    CGFloat inrVal = [[info valueForKey:@"inr"] floatValue];
    NSString *memoVal = (nil == [info valueForKey:@"memo"]) ?@"" : [info valueForKey:@"memo"];

    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO INR_LOG (CHECK_DATE, INR, MEMO) VALUES ('%@', %.1f, '%@')", dateVal, inrVal, memoVal];
    [_inrDB executeUpdate:insertSql];
    
    return YES;
}

- (void)updateSettings
{
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE SETTING SET USERNAME='%@', INR_TARGET=%@, INR_MIN=%@, INR_MAX=%@",
                           [_settings valueForKey:@"name"],
                           [_settings valueForKey:@"target"],
                           [_settings valueForKey:@"min"],
                           [_settings valueForKey:@"max"]];
    NSLog(@"running sql: %@", updateSql);
    [_inrDB executeUpdate:updateSql];
}

@end
