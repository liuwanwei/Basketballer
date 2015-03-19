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
@property (nonatomic) NSInteger points;             // 总分
@property (nonatomic) NSInteger onePoint;           // 罚球
@property (nonatomic) NSInteger onePointMissed;     // 罚球未进
@property (nonatomic) NSInteger towPoints;          // 两分
@property (nonatomic) NSInteger towPointsMissed;    // 两分未进
@property (nonatomic) NSInteger threePoints;        // 三分
@property (nonatomic) NSInteger threePointsMissed;  // 三分未进

// 篮板
@property (nonatomic) NSInteger rebounds;            // 总篮板，不区分前后场时用的统计数据
@property (nonatomic) NSInteger backCourtRebounds;   // 后场
@property (nonatomic) NSInteger foreCourtRebounds;   // 前场

// 助攻
@property (nonatomic) NSInteger assistants;
// 盖帽
@property (nonatomic) NSInteger block;
// 失误
@property (nonatomic) NSInteger miss;
// 抢断
@property (nonatomic) NSInteger steal;
// 犯规
@property (nonatomic) NSInteger fouls;

// 暂停：球队属性，个人技术统计中没有这个数据
@property (nonatomic) NSInteger timeouts;

@end
