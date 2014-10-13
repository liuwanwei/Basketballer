//
//  ActionRecordCell.m
//  Basketballer
//
//  Created by maoyu on 14-10-12.
//
//

#import "ActionRecordCell.h"
#import "TeamManager.h"
#import "AppDelegate.h"
#import "ActionManager.h"
#import "PlayerManager.h"

@implementation ActionRecordCell

#pragma 私有函数
- (void)showHostView:(BOOL)show {
    self.hostActionLabel.hidden = !show;
    self.hostPlayerLabel.hidden = !show;
    self.hostSeparateView.hidden = !show;
    self.guestActionLabel.hidden = show;
    self.guestPlayerLabel.hidden = show;
    self.guestSeparateView.hidden = show;
}

#pragma 事件函数
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil] ;
        self = [nib objectAtIndex:0];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAction:(Action *)action {
    _action = action;
    
    NSString * actionStr;
    switch ([action.type intValue]) {
        case ActionType1Point:
            actionStr = LocalString(@"1PTS");
            break;
        case ActionType2Points:
            actionStr = LocalString(@"2PTS");
            break;
        case ActionType3Points:
            actionStr = LocalString(@"3PTS");
            break;
        case ActionTypeFoul:
            actionStr = LocalString(@"PF");
            break;
        case ActionTypeTimeoutRegular:
            actionStr = LocalString(@"TO");
            break;
            
        default:
            break;
    }
    
    NSString * playerStr = @"";
    if (nil != action.player) {
        Player * player = [[PlayerManager defaultManager] playerWithId:action.player];
        playerStr = player.name;
    }
    
    if (self.hostId == action.team) {
        [self showHostView:YES];
        self.hostActionLabel.text = actionStr;
        self.hostPlayerLabel.text = playerStr;
    }else {
        [self showHostView:NO];
        self.guestActionLabel.text = actionStr;
        self.guestPlayerLabel.text = playerStr;
    }
    
       //时间
    NSInteger time = [action.time intValue];
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", time/60,time%60];
}

@end
