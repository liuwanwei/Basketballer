//
//  MatchPartStatisticCell.m
//  Basketballer
//
//  Created by sungeo on 14-10-8.
//
//

#import "StatisticCell.h"
#import "ActionManager.h"

@implementation StatisticCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStatistic:(Statistics *)statistics{
    self.nameLabel.text = statistics.name;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.points];
    self.reboundsLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.rebounds];
    self.assistLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.assistants];
    self.foulLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.fouls];
    self.threePointsLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.threePoints];
    self.freeThrowLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.freeThrows];
}


@end
