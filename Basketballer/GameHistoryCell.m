//
//  GameHistoryCellTableViewCell.m
//  Basketballer
//
//  Created by sungeo on 14-10-6.
//
//

#import "GameHistoryCell.h"

@implementation GameHistoryCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    float radius = 10.0f;
    self.hostImageView.clipsToBounds = YES;
    self.hostImageView.layer.cornerRadius = radius;
    self.guestImageView.clipsToBounds = YES;
    self.guestImageView.layer.cornerRadius = radius;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
