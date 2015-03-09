//
//  BCMultiActionView.m
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCMultiActionView.h"
#import <Masonry.h>

static const CGFloat ActionViewWidth = 140.f;

@implementation BCMultiActionView

- (id)initInView:(UIView *)view{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        // 添加自身到父视图
        [view addSubview:self];
        __weak UIView * superView = view;
        [self mas_makeConstraints:^(MASConstraintMaker * make){
            make.right.equalTo(superView.mas_right).offset(-8.0f);
            make.width.equalTo(@(ActionViewWidth));
            make.centerY.equalTo(superView.mas_centerY);
        }];
        
        // 初始化右边两个按钮，从右到左
        _buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setBackgroundImageForButton:_buttonRight];
        [self addSubview:_buttonRight];
        superView = self;
        [_buttonRight mas_makeConstraints:^(MASConstraintMaker * make){
            make.trailing.equalTo(superView.mas_right);
            make.centerY.equalTo(superView.mas_centerY);
            make.width.equalTo(@(ActionViewWidth / 2));
            make.height.equalTo(superView.mas_height);
        }];
        
        // 分割线
        _seperator = [[UIView alloc] init];
        _seperator.backgroundColor = [UIColor blueColor];
        _seperator.hidden = YES;
        [self addSubview:_seperator];
        [_seperator mas_makeConstraints:^(MASConstraintMaker * make){
            make.trailing.equalTo(_buttonRight.mas_left).offset(-5.0f);
            make.width.equalTo(@1);
            make.height.equalTo(superView.mas_height);
            make.centerY.equalTo(superView.mas_centerY);
        }];
        
        _buttonLeft = [[UIButton alloc] init];
        [self setBackgroundImageForButton:_buttonLeft];
        [self addSubview:_buttonLeft];
        [_buttonLeft mas_makeConstraints:^(MASConstraintMaker * make){
            make.trailing.equalTo(_seperator.mas_left).offset(-5.0f);
            make.centerY.equalTo(superView.mas_centerY);
            make.width.equalTo(_buttonRight.mas_width);
            make.height.equalTo(superView.mas_height);
        }];

    }
    
    return self;
}

- (void)setBackgroundImageForButton:(UIButton *)button{
    [button setBackgroundImage:[UIImage imageNamed:@"game_menu_on"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"game_menu_off"] forState:UIControlStateHighlighted];
}

- (void)setLeftButtonText:(NSString *)leftText rightButtonText:(NSString *)rightText{
    [self setText:leftText forButton:_buttonLeft];
    [self setText:rightText forButton:_buttonRight];
}

- (void)setText:(NSString *)text forButton:(UIButton *)button{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:17.f];
    
    [button setTitle:text forState:UIControlStateNormal];
}

@end
