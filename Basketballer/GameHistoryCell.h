//
//  GameHistoryCellTableViewCell.h
//  Basketballer
//
//  Created by sungeo on 14-10-6.
//
//

#import <UIKit/UIKit.h>

@interface GameHistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView * hostImageView;
@property (nonatomic, weak) IBOutlet UILabel * hostNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * hostPointLabel;

@property (nonatomic, weak) IBOutlet UILabel * gameTimeLabel;

@property (nonatomic, weak) IBOutlet UIImageView * guestImageView;
@property (nonatomic, weak) IBOutlet UILabel * guestNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * guestPointLabel;

@end
