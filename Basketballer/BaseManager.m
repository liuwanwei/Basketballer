//
//  BaseManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseManager.h"
#import "AppDelegate.h"

static NSString * sFilePath = nil;
static NSMutableDictionary * sIdDictionary = nil;

@implementation BaseManager

@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext == nil) {
        AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = delegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

// id generator: We assume that id will never beyond maxium value represented by 'NSInteger'.
+ (NSNumber *)generateIdForKey:(NSString *)key{
    if (sFilePath == nil) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        sFilePath = [documentsDirectory stringByAppendingPathComponent:@"idGenerator.txt"];
    }
    
    if (sIdDictionary == nil) {
        sIdDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:sFilePath];
        if (sIdDictionary == nil) {
            sIdDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    
    NSNumber * nextMaxId = nil;
    NSNumber * maxId = [sIdDictionary objectForKey:key];
    if (maxId != nil) {
        // Prepare the maxium id for the next call.
        nextMaxId = [NSNumber numberWithInteger:[maxId integerValue] + 1];
    }else{
        // If this is the first time we use this generator, 
        // make 0 the maxium id, 1 the next.
        maxId = [NSNumber numberWithInteger:1];
        nextMaxId = [NSNumber numberWithInteger:2];
    }
    
    [sIdDictionary setObject:nextMaxId forKey:key];
    [sIdDictionary writeToFile:sFilePath atomically:YES];
    
    return maxId;    
}

- (BOOL)synchroniseToStore{
    NSError * error = nil;
    if (! [self.managedObjectContext save:&error]) {
        NSLog(@"save error: %@", [error description]);
        return NO;        
    }
    
    return YES;
}

- (BOOL)deleteFromStore:(id)record synchronized:(BOOL)synchronized{
    [self.managedObjectContext deleteObject:record];
    
    if (synchronized) {
        if (! [self synchroniseToStore]) {
            return NO;
        }
    }
    
    return YES;
}

@end
