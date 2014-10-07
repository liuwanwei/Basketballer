//
//  ImageCell.m
//  Basketballer
//
//  Created by sungeo on 14-9-28.
//
//

#import "ImageCell.h"

@implementation ImageCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    // 图片圆角化。
//    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.cornerRadius = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
