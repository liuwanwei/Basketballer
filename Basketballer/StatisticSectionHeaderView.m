//
//  StatisticHeaderView.m
//  Basketballer
//
//  Created by sungeo on 14-10-7.
//
//

#import "StatisticSectionHeaderView.h"

@implementation StatisticSectionHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)changeToPeriodStatistics{
    self.pointsLabel.text = @"1st";
    self.reboundsLabel.text = @"2nd";
    self.assistsLabel.text = @"3rd";
    self.threePointsLabel.text = @"4th";
    self.freeThrowLabel.text = @"加时";
    self.foulLabel.text = @"总分";
}

@end
