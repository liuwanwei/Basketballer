//
//  GameSettingFormViewController.h
//  Basketballer
//
//  Created by sungeo on 15/2/21.
//
//

#import <XLForm.h>
#import "BaseRule.h"

@interface GameSettingFormViewController : XLFormViewController<UIAlertViewDelegate>

@property (nonatomic, strong) BaseRule * ruleInUse;

@end
