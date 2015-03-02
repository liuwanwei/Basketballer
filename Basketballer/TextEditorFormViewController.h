//
//  TextEditorFormViewController.h
//  Basketballer
//
//  Created by sungeo on 15/3/2.
//
//

#import "XLFormViewController.h"

// 文本已经保存消息，向调用界面发出，通过Notification方式。
#define kTextSavedMsg          @"TextSavedMsg"

@interface TextEditorFormViewController : XLFormViewController

@property (nonatomic) NSInteger keyboardType;           // [in]
@property (nonatomic, copy) NSString * textKeyword;     // [in]
@property (nonatomic, copy) NSString * textToEdit;      // [in/out]


- (instancetype)initWithTitle:(NSString *)title;

@end
