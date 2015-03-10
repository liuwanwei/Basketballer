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

@property (nonatomic) NSInteger keyboardType;           // [in] 键盘类型，跟系统提供的保持一致
@property (nonatomic, copy) NSString * textKeyword;     // [in] 用来区分编辑同一界面不同文本的情况，
                                                        //      作为NSDictionary的key填充到NSNotification.userInfo中
@property (nonatomic, copy) NSString * textToEdit;      // [in/out]

// 必须初始化时制定标题
- (instancetype)initWithTitle:(NSString *)title;

@end
