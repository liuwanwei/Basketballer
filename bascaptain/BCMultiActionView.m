//
//  BCMultiActionView.m
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCMultiActionView.h"
#import <Masonry.h>
#import "Macro.h"

static const CGFloat ActionViewWidth = 200.f;

@implementation BCMultiActionView{
    NSArray * _buttons;
    NSArray * _seperators;
}

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
        [self addSubview:_buttonRight];
        superView = self;
        [_buttonRight mas_makeConstraints:^(MASConstraintMaker * make){
            make.trailing.equalTo(superView.mas_right);
            make.centerY.equalTo(superView.mas_centerY);
            make.width.equalTo(@(ActionViewWidth / 2));
            make.height.equalTo(superView.mas_height);
        }];
        
        // 分割线
        [self addSeperatorBesidesRightView:_buttonRight];
        
        _buttonLeft = [[UIButton alloc] init];
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

- (void)addSeperatorBesidesRightView:(UIView *)rightView{
    __weak UIView * superView = self;
    
    _seperator = [[UIView alloc] init];
    _seperator.hidden = YES;
    [self addSubview:_seperator];
    [_seperator mas_makeConstraints:^(MASConstraintMaker * make){
        make.trailing.equalTo(rightView.mas_left).offset(-5.0f);
        make.width.equalTo(@1);
        make.height.equalTo(superView.mas_height);
        make.centerY.equalTo(superView.mas_centerY);
    }];
}

- (void)setBackgroundImageForButton:(UIButton *)button{
    // 设置圆角：直径为按钮高度
    CGFloat radius = self.bounds.size.height / 2;
    button.layer.cornerRadius = radius;
    button.clipsToBounds = YES;
//    NSLog(@"height %d, radius %.1f", (int)self.bounds.size.height, radius);
    
    // 设置背景色
    [button setBackgroundColor:RGB(0x5c, 0xb3, 0xf0)];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
}

- (void)updateActionButton{
    // 调用后，圆角化按钮时才能得到高度
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self setBackgroundImageForButton:_buttonLeft];
    [self setBackgroundImageForButton:_buttonRight];
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
