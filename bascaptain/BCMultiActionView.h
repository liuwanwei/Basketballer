//
//  BCMultiActionView.h
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import <UIKit/UIKit.h>

@interface BCMultiActionView : UIView

@property (nonatomic, strong) UIButton * buttonLeft;
@property (nonatomic, strong) UIButton * buttonRight;
@property (nonatomic, strong) UIView * seperator;

- (id)initInView:(UIView *)view;
- (void)setLeftText:(NSString *)leftText rightText:(NSString *)rightText;

@end