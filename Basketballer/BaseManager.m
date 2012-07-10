//
//  BaseManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseManager.h"
#import "AppDelegate.h"

@implementation BaseManager

@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext == nil) {
        AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = delegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (BOOL)synchroniseToStore{
    NSError * error = nil;
    if (! [self.managedObjectContext save:&error]) {
        NSLog(@"save error: %@", [error description]);
        return NO;        
    }
    
    return YES;
}

- (BOOL)deleteFromStore:(id)record{
    [self.managedObjectContext deleteObject:record];
    
    if (! [self synchroniseToStore]) {
        return NO;
    }
    
    return YES;
}

@end
