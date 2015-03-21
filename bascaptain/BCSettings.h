//
//  BCSettings.h
//  Basketballer
//
//  Created by sungeo on 15/3/21.
//
//

#import <Foundation/Foundation.h>

@interface BCSettings : NSObject

@property (nonatomic) BOOL guestTeamAddScroreNoticeFlag;

+ (instancetype)defaultInstance;

@end
