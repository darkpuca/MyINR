//
//  AppDelegate.h
//  MyINR
//
//  Created by darkpuca on 10/4/12.
//  Copyright (c) 2012 darkpuca. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *naviController;
@property (nonatomic, strong) FMDatabase *inrDB;
@property (nonatomic, strong) NSMutableDictionary *settings;

- (NSString *)databaseFilePath;


- (BOOL)insertNewData:(NSDictionary *)info;
- (void)updateSettings;

@end
