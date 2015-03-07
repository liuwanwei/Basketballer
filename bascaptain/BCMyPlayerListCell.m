//
//  MyTeamPlayerListCell.m
//  Basketballer
//
//  Created by sungeo on 15/3/7.
//
//

#import "BCMyPlayerListCell.h"

@implementation BCMyPlayerListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showPlayer:(Player *)player{
    self.labelName.text = player.name;
    self.labelNumber.text = [player.number stringValue];
}

@end
