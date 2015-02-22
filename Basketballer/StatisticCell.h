//
//  MatchPartStatisticCell.h
//  Basketballer
//
//  Created by sungeo on 14-10-8.
//
//

#import <UIKit/UIKit.h>

@class Statistics;

@interface StatisticCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * reboundsLabel;
@property (nonatomic, weak) IBOutlet UILabel * assistLabel;
@property (nonatomic, weak) IBOutlet UILabel * threePointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * freeThrowLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulLabel;

- (void)setStatistic:(Statistics *)statistics;

- (void)setPeriodPoints:(NSDictionary *)dictionary withTeamName:(NSString *)teamName;
- (void)setTotalPoints:(NSNumber *)points;
    
@end
