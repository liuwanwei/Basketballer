//
//  MatchPartStatisticCell.h
//  Basketballer
//
//  Created by sungeo on 14-10-8.
//
//

#import <UIKit/UIKit.h>

@interface MatchPartStatisticCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * threePointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * freeThrowLabel;
@property (nonatomic, weak) IBOutlet UILabel * foulLabel;

- (void)setStatistic:(NSDictionary *)statistics;
    
@end
