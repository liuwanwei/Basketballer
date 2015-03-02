//
//  TextEditorFormViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/2.
//
//

#import "TextEditorFormViewController.h"
#import <XLForm.h>

NSString * const kTextField = @"TextField";

@interface TextEditorFormViewController()

@property (nonatomic, weak) XLFormRowDescriptor * textRow;

@end

@implementation TextEditorFormViewController

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]) {
        [self initializeFormWithTitle:title];
    }
    
    return self;
}

- (void)initializeFormWithTitle:(NSString *)title{
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:title];
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:kTextField rowType:XLFormRowDescriptorTypeText];
    self.textRow = row;
    [section addFormRow:row];
    
    self.form = form;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.textRow.value = self.textToEdit;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSString * text = self.textRow.value;
    
    if (text.length != 0) {
        NSLog(@"发送文本保存事件");
        NSString * key = (self.textKeyword == nil ? kTextSavedMsg : self.textKeyword);
        [[NSNotificationCenter defaultCenter] postNotificationName:kTextSavedMsg object:self userInfo:@{key:text}];
    }
}


@end
