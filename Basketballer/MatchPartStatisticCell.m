//
//  MatchPartStatisticCell.m
//  Basketballer
//
//  Created by sungeo on 14-10-8.
//
//

#import "MatchPartStatisticCell.h"
#import "ActionManager.h"

@implementation MatchPartStatisticCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStatistic:(NSDictionary *)statistics{
    self.nameLabel.text = [statistics objectForKey:kName];
    self.pointsLabel.text = [statistics objectForKey:kPoints];
    self.foulLabel.text = [statistics objectForKey:kPersonalFouls];
    self.threePointsLabel.text = [statistics objectForKey:k3PointMade];
    self.freeThrowLabel.text = [statistics objectForKey:kFreeThrow];
}


@end
