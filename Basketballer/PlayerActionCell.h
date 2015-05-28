//
//  PointsActionCell.h
//  Basketballer
//
//  Created by sungeo on 15/5/22.
//
//

#import <UIKit/UIKit.h>

#import "ActionManager.h"

extern NSString * const DismissPlayerActionView;

@class Player;

@interface PlayerActionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * labelNumber;
@property (nonatomic, weak) IBOutlet UILabel * labelName;
@property (nonatomic, weak) IBOutlet UILabel * labelFoul;
@property (nonatomic, weak) IBOutlet UIButton * buttonLeft;
@property (nonatomic, weak) IBOutlet UIButton * buttonRight;

@property (nonatomic, strong) UIColor * leftButtonColor;
@property (nonatomic, strong) UIColor * rightButtonColor;

@property (nonatomic, weak) Player * player;

- (void)customWithActionType:(ActionType)type andPlayer:(Player *)player;

@end
