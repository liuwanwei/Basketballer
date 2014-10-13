//
//  ActionRecordCell.h
//  Basketballer
//
//  Created by maoyu on 14-10-12.
//
//

#import <UIKit/UIKit.h>
#import "Action.h"

@interface ActionRecordCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * hostActionLabel;
@property (nonatomic, weak) IBOutlet UILabel * hostPlayerLabel;
@property (nonatomic, weak) IBOutlet UIView * hostSeparateView;
@property (nonatomic, weak) IBOutlet UILabel * guestActionLabel;
@property (nonatomic, weak) IBOutlet UILabel * guestPlayerLabel;
@property (nonatomic, weak) IBOutlet UIView * guestSeparateView;
@property (nonatomic, weak) IBOutlet UILabel * timeLabel;

@property (nonatomic, strong) NSNumber * hostId;
@property (nonatomic, strong) NSNumber * guestId;
@property (nonatomic, strong) Action * action;

@end
