//
//  WellKnownSaying.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WellKnownSaying.h"

static WellKnownSaying * sDefaultObject;

@interface WellKnownSaying(){
    NSURLConnection * _connection;
}

@end

@implementation WellKnownSaying

@synthesize allSayings = _allSayings;
@synthesize index = _index;
@synthesize responseData = _responseData;

+ (WellKnownSaying *)defaultSaying{
    if (sDefaultObject == nil) {
        sDefaultObject = [[WellKnownSaying alloc] init];
    }
    return sDefaultObject;
}

- (id)init{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)addSaying:(NSString *)words byWhom:(NSString *)whom{
    if(nil == _allSayings){
        _allSayings = [[NSMutableArray alloc] init];
    }
    
    NSDictionary * saying = [NSDictionary dictionaryWithObjectsAndKeys:words, kWords, whom, kWhom, nil];
    [_allSayings addObject:saying];
}

- (void)createDefaultSaying{
    [self addSaying:@"Some people want it to happen, some wish it would happen, others make it happen." 
          byWhom:@"Michael Jordan"];
}

- (NSDictionary *)oneSaying{
    if (nil == _allSayings) {
        [self createDefaultSaying];
    }
        
    NSDictionary * saying = [_allSayings objectAtIndex:_index];
    _index = (_index + 1) % _allSayings.count;
    return saying;
}

- (NSDictionary *)lastSaying{
    if (nil != _allSayings && _allSayings.count > 0) {
        return [_allSayings objectAtIndex:_allSayings.count - 1];
    }else{
        return nil;
    }
}

- (void)requestSaying{
    self.responseData = [[NSMutableData alloc] init];
    
    NSURL * url = [NSURL URLWithString:@"http://speak1.sinaapp.com/latest.php?n=10"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)postNewSayingCommingMessage{
    NSNotification * notification = [NSNotification notificationWithName:kNewSayingMessage object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (_responseData) {
        [_responseData appendData:data];
    }
}

- (BOOL)checkJsonValue:(id)value{
    return [value isKindOfClass:[NSString class]];
}

- (BOOL)fetchSaying:(NSDictionary *)wrapped{
    id words = [wrapped objectForKey:kWords];
    if (! [self checkJsonValue:words]) {
        return NO;
    }
    
    id whom = [wrapped objectForKey:kWhom];
    if (![self checkJsonValue:whom]) {
        return NO;
    }
    
    [self addSaying:words byWhom:whom];    
    
    return YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSError * error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&error];
    if ([json isKindOfClass:[NSArray class]]) {
        NSArray * jsonArray = (NSArray *)json;
        for (int i = 0; i < jsonArray.count; i++) {
            id object = [jsonArray objectAtIndex:i];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [self fetchSaying:object];
            }
        }
    }else if([json isKindOfClass:[NSDictionary class]]){
        [self fetchSaying:json];
    }
}

@end
