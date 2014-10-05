//
//  AppDelegate.m
//  Basketballer
//
//  Created by maoyu on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MatchManager.h"
#import "TeamManager.h"
#import "CustomRuleManager.h"
#import "PlayGameViewController.h"
#import "GameSetting.h"
#import "Feature.h"
#import "MatchUnderWay.h"
#import "WellKnownSaying.h"
#import <UIKit/UIKit.h>

typedef enum {
    NotificationBodyForCommonTimeout = 0,
    NotificationBodyForCommonQuarterTime = 1,
    NotificationBodyForCommonShowApp = 2
}NotificationBodyForCommon;

#define kOTIndexOfBodyArray 4

@interface AppDelegate () {
    NSArray * _notificationBodyFor4Quarter;
    NSArray * __weak _notificationBody;
    NSArray * _notificationBodyForCommon;
    NSDate * _enterBackgroundDate;
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize playGameViewController = _playGameViewController;

#pragma 私有函数

- (void)initNotificationBodyArray {
    _notificationBodyFor4Quarter = [NSArray arrayWithObjects:
                                    LocalString(@"Period1End"),
                                    LocalString(@"Period2End"),
                                    LocalString(@"Period3End"),
                                    LocalString(@"Period4End"),
                                    LocalString(@"OvertimeEnd"), 
                                    nil];
    _notificationBody = _notificationBodyFor4Quarter;
    _notificationBodyForCommon = [NSArray arrayWithObjects:
                                  LocalString(@"TimeoutTimeUp"),
                                  LocalString(@"RestTimeUp"),
                                  LocalString(@"CheckApp"), 
                                  nil];
}

- (void)updateCountdownTime {
    if (_enterBackgroundDate) {
        NSDate * date = [NSDate date];
        NSInteger elapsedTime = [date timeIntervalSinceDate:_enterBackgroundDate];
        MatchUnderWay * match = [MatchUnderWay defaultMatch];
        match.timeoutCountdownSeconds > 0 ? 
        (match.timeoutCountdownSeconds = match.timeoutCountdownSeconds - elapsedTime) :
        (match.countdownSeconds = match.countdownSeconds - elapsedTime);
    }
    
    _enterBackgroundDate = nil;
}

/*
 后台提示比赛消息。
 当比赛进行中或暂停中进入后台时，向UILocalNotification注册事件。
 注：比赛模式为抢球模式除外。
 */
- (void)addLocalNotification {
    if (self.playGameViewController != nil) {
        _enterBackgroundDate = nil;
        UILocalNotification * newNotification = nil;
        NSString * body;
        MatchUnderWay * match = [MatchUnderWay defaultMatch];
        if ([match.matchMode isEqualToString:kMatchModeAccount]) {
            return;
        }
        
        if (match.state == MatchStatePlaying) {
            newNotification = [[UILocalNotification alloc] init];
            newNotification.fireDate = [match periodFinishingDate];
            NSInteger index = match.period < MatchPeriodOvertime ? match.period : kOTIndexOfBodyArray;
            body = [_notificationBody objectAtIndex:index];
        }else if (match.state == MatchStateTimeout) {
            newNotification = [[UILocalNotification alloc] init];
            body = [_notificationBodyForCommon objectAtIndex:NotificationBodyForCommonTimeout];
            newNotification.fireDate = [match timeoutFinishingDate];
        }else if (match.state == MatchStateQuarterTime) {
            newNotification = [[UILocalNotification alloc] init];
            body = [_notificationBodyForCommon objectAtIndex:NotificationBodyForCommonQuarterTime];
            newNotification.fireDate = [match timeoutFinishingDate];
        }
        
        if (newNotification != nil) {
            _enterBackgroundDate = [NSDate date];
            newNotification.alertBody = body;
            newNotification.soundName = UILocalNotificationDefaultSoundName;
            newNotification.alertAction = [_notificationBodyForCommon objectAtIndex:NotificationBodyForCommonShowApp];
            newNotification.timeZone=[NSTimeZone defaultTimeZone]; 
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        }
    }
}

#pragma 事件函数
+ (AppDelegate *)delegate{
	AppDelegate * delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	return delegate;
}

- (void)presentModelViewController:(UIViewController *)controller{
    [self.tabBarController presentViewController:controller animated:YES completion:nil];
}

- (void)dismissModelViewController{
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

// 初始化所有子Tab中导航栏的效果（顶部）
- (void)initNavigationBarBgColor{
    return; //TODO
//    NSArray * navControllers = self.tabBarController.viewControllers;
//    for (UINavigationController * nav in navControllers) {
//        [[Feature defaultFeature] customNavigationBar:nav.navigationBar];
//    }
}

// 初始化TabBar的效果（屏幕底部的TabBar）
- (void)initTabBar {
    NSArray * titles = [NSArray arrayWithObjects:
                        NSLocalizedString(@"Start", nil),
                        NSLocalizedString(@"Teams", nil),
                        NSLocalizedString(@"Histories", nil),
                        NSLocalizedString(@"Others", nil), 
                        nil];
    
    [self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbarBackground"]];
    
    // 修改Tab的文字效果，显示国际化的文字内容
    NSInteger size = self.tabBarController.tabBar.items.count;
    for (NSInteger index = 0; index < size; index++) {
        UITabBarItem * item = [self.tabBarController.tabBar.items objectAtIndex:index];
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIFont fontWithName:@"Arial" size:11.0],UITextAttributeFont,nil] forState:UIControlStateNormal];
        item.title = [titles objectAtIndex:index];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MatchManager defaultManager] loadMatches];
    [[TeamManager defaultManager] loadTeams];
    [[CustomRuleManager defaultInstance] loadRules];
    
    [self initNavigationBarBgColor];
    [self initTabBar];
    [self initNotificationBodyArray];
    
    application.statusBarStyle = UIStatusBarStyleDefault;
    
    //[[WellKnownSaying defaultSaying] requestSaying];
    
//    [self.window addSubview:self.tabBarController.view];
    [self.window setRootViewController:self.tabBarController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self addLocalNotification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self updateCountdownTime];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Basketballer" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Basketballer.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
