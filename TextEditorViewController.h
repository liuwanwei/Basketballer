//
//  TextEditorViewController.h
//  Basketballer
//
//  Created by sungeo on 14-9-28.
//
//

// 文本已经保存消息，向调用界面发出，通过Notification方式。
#define kTextSavedMsg          @"TextSavedMsg"

#import <UIKit/UIKit.h>

@interface TextEditorViewController : UIViewController

@property (nonatomic) NSInteger keyboardType;       // [in]

@property (nonatomic, copy) NSString * text;        // [in/out]

@property (nonatomic, weak) IBOutlet UITextField * textField;

@end
