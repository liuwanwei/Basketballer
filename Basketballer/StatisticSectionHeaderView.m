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

- (void)hideStatisticLabel{
    self.pointsLabel.hidden = YES;
    self.threePointsLabel.hidden = YES;
    self.freeThrowLabel.hidden = YES;
    self.foulLabel.hidden = YES;
}

@end
