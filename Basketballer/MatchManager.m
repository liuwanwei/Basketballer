//
//  MatchManager.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MatchManager.h"
#import "AppDelegate.h"

static MatchManager * sDefaultManager;

@implementation MatchManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize matchesArray = _matchesArray;

+ (MatchManager *)defaultManager{
    if (sDefaultManager == nil) {
        sDefaultManager = [[MatchManager alloc] init];
    }
    return sDefaultManager;
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext == nil) {
        AppDelegate * delegate = [[UIApplication sharedApplication] delegate]; 
        _managedObjectContext = delegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (void)loadMatches{
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:kMatchEntity];

    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.sortDescriptors = sortDescriptors;
    
    NSError * error = nil;
    // TODO why mutableCopy?
    NSMutableArray * mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (nil == mutableFetchResults) {
        NSLog(@"executeFetchRequest: %@", [error description]);
        return;
    }
    
    self.matchesArray = mutableFetchResults;
}

// 生成一个不会重复的比赛id     
- (NSNumber *)idGenerator{
    NSMutableIndexSet * idSet = [[NSMutableIndexSet alloc] init];
    for (Match * match in _matchesArray) {
        [idSet addIndex:[[match id] integerValue]];
    }
    
    NSInteger id = 0;
    while ([idSet containsIndex:id]) {
        id ++;
    }
    
    return [NSNumber numberWithInteger:id];
}

- (Match *)newMatchWithMode:(NSString *)mode{
    Match * newOne = (Match *)[NSEntityDescription insertNewObjectForEntityForName:kMatchEntity 
                            inManagedObjectContext:self.managedObjectContext];
    // 默认填充当前时间作为比赛时间。
    newOne.date = [NSDate date];
    
    newOne.id = [self idGenerator];
    
    if(! [self save]){
        return nil;
    }
    
    [self.matchesArray insertObject:newOne atIndex:0];
    
    return newOne;
}

- (BOOL)deleteMatch:(Match *)match{
    [self.managedObjectContext deleteObject:match];
    
    if (! [self save]) {
        return NO;
    }
    
    [self.matchesArray removeObject:match];
    
    return YES;
}

- (BOOL)save{
    NSError * error = nil;
    if (! [self.managedObjectContext save:&error]) {
        NSLog(@"save error: %@", [error description]);
        return NO;        
    }
    
    return YES;
}

@end
