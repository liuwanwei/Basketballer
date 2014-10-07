//
//  StatisticHeaderView.h
//  Basketballer
//
//  Created by sungeo on 14-10-7.
//
//

#import <UIKit/UIKit.h>

@interface StatisticSectionHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * threePointsLabel;
@property (nonatomic, weak) IBOutlet UILabel * freeThrowLabel;
@property (nonatomic, weak) IBOutlet UILabel * faultLabel;

- (void)hideStatisticLabel;

@end
