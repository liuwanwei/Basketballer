//
//  PointsActionCell.m
//  Basketballer
//
//  Created by sungeo on 15/5/22.
//
//

#import "PlayerActionCell.h"
#import "MatchUnderWay.h"
#import "Player.h"
#import <NSObject+GLPubSub.h>
#import "AppDelegate.h"

NSString * const DismissPlayerActionView = @"DismissPlayerActionView";

typedef enum{
    PlayerCellActionEnabled = 0,
    PlayerCellActionUnEnabled = 1,
}PlayerCellAction;


@implementation PlayerActionCell{
    id _leftButtonTarget;
    id _rightButtonTarget;
    
    SEL _leftButtonSelector;
    SEL _rightButtonSelector;
    
    ActionType _actionType;
}

- (void)awakeFromNib {
    // Initialization code
    
    CGFloat radius = 20;
    
    self.buttonRight.layer.cornerRadius = radius;
    self.buttonRight.clipsToBounds = YES;
    
    self.buttonLeft.layer.cornerRadius = radius;
    self.buttonLeft.clipsToBounds = YES;
    
    [self.buttonLeft addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonRight addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)leftButtonClicked:(id)sender{
    NSLog(@"miss");
    if (! [self checkEnabled]) {
        return;
    }

    ActionType action = _actionType + ActionTypeDetailsBase;
    [self addPlayerAction:action];
}

- (IBAction)rightButtonClicked:(id)sender{
    NSLog(@"score");
    if (! [self checkEnabled]) {
        return;
    }
    
    [self addPlayerAction:_actionType];
}

- (void)addPlayerAction:(ActionType)action{
    // 这里只是选择球员，假如犯规次数已到，应该在上一个NewActionViewController界面就提示。
    // 犯规次数达到罚球次数时，弹出罚球提示对话框，也应该在NewActionViewController中进行。
    
    NSDictionary * userInfo = @{@"playerId":_player.id ? _player.id : [NSNull null],
                                @"actionType":@(action)};
    
    [self publish:DismissPlayerActionView data:userInfo];
}

- (BOOL)checkEnabled{
    if (self.tag == PlayerCellActionUnEnabled) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LocalString(@"Alert")
                                                             message:LocalString(@"OperationForbidden")
                                                            delegate:self
                                                   cancelButtonTitle:LocalString(@"Ok")
                                                   otherButtonTitles:nil , nil];
        [alertView show];
        return NO;
    }else{
        return YES;
    }
}

- (void)customWithActionType:(ActionType)type andPlayer:(Player *)player{
    _player = player;
    _actionType = type;
    
    if (player) {
        self.labelNumber.text = [player.number stringValue];
        self.labelName.text = player.name;
        
        // 设置该球员犯规数
        if (type == ActionTypeFoul) {
            ActionManager * am = [ActionManager defaultManager];
            NSArray * actionsInMatch = [[ActionManager defaultManager] actionArray];
            Statistics * data = [am statisticsForPlayer:player.id inActions:actionsInMatch];
            NSInteger fouls = data.fouls;
            self.labelFoul.text = [NSString stringWithFormat:@"犯规：%d", (int)fouls];
            
            if ([MatchUnderWay defaultMatch].rule.foulLimitForPlayer < fouls) {
                // 球员超出犯规次数，理应被罚出场，名字显示红色
                self.labelFoul.textColor = [UIColor redColor];
                
                // 球员超出犯规次数，犯规数显示红色
                if (type == ActionTypeFoul) {
                    self.labelFoul.textColor = [UIColor redColor];
                }
                
                // 设置不允许添加技术统计标识
                self.tag = PlayerCellActionUnEnabled;
                
            }else{
                self.tag = PlayerCellActionEnabled;
            }
        }else{
            self.labelFoul.text = nil;
        }

    }else{
        self.labelNumber.text = @" *";
        self.labelName.text = @"其他";
        self.labelFoul.text = nil;
    }
    
    if ([ActionManager isPointAction:type]) {
        NSString * desc = nil;
        if (type == ActionType1Point) {
            desc = @"1分";
        }else if(type == ActionType2Points){
            desc = @"2分";
        }else if(type == ActionType3Points){
            desc = @"3分";
        }
        [self.buttonRight setTitle:desc forState:UIControlStateNormal];
        
    }else{
        [self disableLeftButton];
        
        [self.buttonRight setTitle:@"+1" forState:UIControlStateNormal];
    }
}

#pragma mark - Private methods

- (void)disableLeftButton{
    self.buttonLeft.enabled = NO;
    self.buttonLeft.hidden = YES;
}

@end
