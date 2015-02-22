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

// 这个用来展示球队或个人技术统计
- (void)setStatistic:(Statistics *)statistics{
    self.nameLabel.text = statistics.name;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.points];
    self.reboundsLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.rebounds];
    self.assistLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.assistants];
    self.foulLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.fouls];
    self.threePointsLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.threePoints];
    self.freeThrowLabel.text = [NSString stringWithFormat:@"%d", (int)statistics.freeThrows];
}

// ----------------- 下面用来展示球队每节得分

- (void)setStatistics:(Statistics *)statistics toLabel:(UILabel *)label{
    int points = (int)statistics.points;
    label.text = [NSString stringWithFormat:@"%d", points];
    
    if (statistics == nil && label == self.freeThrowLabel) {
        label.text = @"无";
    }
}


// 设置每节得分
- (void)setPeriodPoints:(NSDictionary *)dictionary withTeamName:(NSString *)teamName{
    self.nameLabel.text = teamName;
    
    // 第一节
    [self setStatistics:dictionary[@(MatchPeriodFirst)] toLabel:self.pointsLabel];
    
    // 第二节
    [self setStatistics:dictionary[@(MatchPeriodSecond)] toLabel:self.reboundsLabel];
    
    // 第三节
    [self setStatistics:dictionary[@(MatchPeriodThird)] toLabel:self.assistLabel];
    
    // 第四节
    [self setStatistics:dictionary[@(MatchPeriodFourth)] toLabel:self.threePointsLabel];
    
    // 加时赛
    [self setStatistics:dictionary[@(MatchPeriodOvertime)] toLabel:self.freeThrowLabel];
}

// 设置总分
- (void)setTotalPoints:(NSNumber *)points{
    self.foulLabel.text = [points stringValue];
}


@end
