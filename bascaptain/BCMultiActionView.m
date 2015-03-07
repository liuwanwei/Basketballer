//
//  BCMultiActionView.m
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCMultiActionView.h"
#import <Masonry.h>

@implementation BCMultiActionView

- (id)initInView:(UIView *)view{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        // 添加自身到父视图
        [view addSubview:self];
        __weak UIView * superView = view;
        [self mas_makeConstraints:^(MASConstraintMaker * make){
            make.right.equalTo(superView.mas_right).offset(-8.0f);
            make.width.equalTo(@120);
            make.centerY.equalTo(superView.mas_centerY);
        }];
        
        // 初始化右边两个按钮，从右到左
        _buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_buttonRight];
        superView = self;
        [_buttonRight mas_makeConstraints:^(MASConstraintMaker * make){
            make.trailing.equalTo(superView.mas_right);
            make.centerY.equalTo(superView.mas_centerY);
            make.width.equalTo(@60);
            make.height.equalTo(superView.mas_height);
        }];
        
        _seperator = [[UIView alloc] init];
        _seperator.backgroundColor = [UIColor blueColor];
        [self addSubview:_seperator];
        [_seperator mas_makeConstraints:^(MASConstraintMaker * make){
            make.trailing.equalTo(_buttonRight.mas_left).offset(-5.0f); // TODO: 验证应填正填负
            make.width.equalTo(@1);
            make.height.equalTo(superView.mas_height);
            make.centerY.equalTo(superView.mas_centerY);
        }];
        
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

- (void)setLeftText:(NSString *)leftText rightText:(NSString *)rightText{
    [self.buttonLeft setTitle:leftText forState:UIControlStateNormal];
    [self.buttonLeft setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.buttonLeft setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    
    [self.buttonRight setTitle:rightText forState:UIControlStateNormal];
    [self.buttonRight setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

@end
