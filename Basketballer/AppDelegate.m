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
#import "PlayGameViewController.h"
#import "define.h"
#import "GameSetting.h"

@implementation AppDelegate

@synthesize window = _window;
//@synthesize navigationController = _navigationController;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize playGameViewController = _playGameViewController;

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

- (void)initNavigationBarBgColor{
    UIImage * image = [UIImage imageNamed:@"ZhiHuNavigationBar"];
    NSArray * navControllers = self.tabBarController.viewControllers;
    for (UINavigationController * nav in navControllers) {
        [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MatchManager defaultManager] loadMatches];
    [[TeamManager defaultManager] loadTeams];
    
    [self initNavigationBarBgColor];
    
    [self.window addSubview:self.tabBarController.view];
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
    if (self.playGameViewController != nil) {
        UILocalNotification *newNotification = [[UILocalNotification alloc] init];
        NSString * body;
        if (self.playGameViewController.gameState == playing) {
            if (newNotification) {
                newNotification.fireDate = self.playGameViewController.targetTime;
                if (self.playGameViewController.curPeroid == 0) {
                    body = @"第一节比赛结束";
                }else if (self.playGameViewController.curPeroid == 1){
                    if (self.playGameViewController.gameMode == kGameModeTwoHalf) {
                        body = @"整场比赛结束";
                    }else {
                        body = @"第二节比赛结束";
                    }
                }else if(self.playGameViewController.curPeroid == 2){
                    body = @"第三节比赛结束";
                }else if(self.playGameViewController.curPeroid ==3) {
                    body = @"整场比赛结束";
                }else {
                    body = @"本节比赛结束";
                }
                newNotification.alertBody = body;
                newNotification.soundName = UILocalNotificationDefaultSoundName;
                newNotification.alertAction = @"查看应用";
                newNotification.timeZone=[NSTimeZone defaultTimeZone]; 
                [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
            }
        }else if(self.playGameViewController.gameState == timeout || self.playGameViewController.gameState == over_quarter_finish){
            body = @"暂停时间到";
            newNotification.fireDate = self.playGameViewController.timeoutTargetTime;
            newNotification.alertBody = body;
            newNotification.soundName = UILocalNotificationDefaultSoundName;
            newNotification.alertAction = @"查看应用";
            newNotification.timeZone=[NSTimeZone defaultTimeZone]; 
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
