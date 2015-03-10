//
//  MyTeamPlayerListCell.m
//  Basketballer
//
//  Created by sungeo on 15/3/7.
//
//

#import "BCMyPlayerListCell.h"
#import "ImageManager.h"

@implementation BCMyPlayerListCell

- (void)awakeFromNib {
    // Initialization code
    self.imageViewHead.layer.cornerRadius = self.imageViewHead.frame.size.width / 2;
    self.imageViewHead.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showPlayer:(Player *)player{
    self.labelName.text = player.name;
    self.labelNumber.text = [NSString stringWithFormat:@"%@号", player.number];
    self.imageViewHead.image = [[ImageManager defaultInstance] imageForName:player.profileURL];
}

@end
