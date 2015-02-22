//
//  Statistics.h
//  技术统计信息，用于球队或球员技术统计
//
//  Created by sungeo on 15/2/22.
//
//

#import <Foundation/Foundation.h>

@interface Statistics : NSObject

@property (nonatomic, copy) NSString * name;

// 得分
@property (nonatomic) NSInteger points;
@property (nonatomic) NSInteger freeThrows;
@property (nonatomic) NSInteger threePoints;

// 篮板
@property (nonatomic) NSInteger rebounds;
// 助攻
@property (nonatomic) NSInteger assistants;
// 暂停
@property (nonatomic) NSInteger timeouts;
// 犯规
@property (nonatomic) NSInteger fouls;

@end
