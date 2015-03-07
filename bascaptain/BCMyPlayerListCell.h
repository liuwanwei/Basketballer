//
//  MyTeamPlayerListCell.h
//  Basketballer
//
//  Created by sungeo on 15/3/7.
//
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface BCMyPlayerListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * imageViewHead;
@property (nonatomic, weak) IBOutlet UILabel * labelName;
@property (nonatomic, weak) IBOutlet UILabel * labelNumber;
@property (nonatomic, weak) IBOutlet UILabel * labelAveragePoints;
@property (nonatomic, weak) IBOutlet UILabel * labelAverageRebounds;
@property (nonatomic, weak) IBOutlet UILabel * labelAverageAssists;

- (void)showPlayer:(Player *)player;

@end
