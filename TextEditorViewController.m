//
//  TextEditorViewController.m
//  Basketballer
//
//  Created by sungeo on 14-9-28.
//
//

#import "TextEditorViewController.h"

@interface TextEditorViewController ()

@end

@implementation TextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.keyboardType = UIKeyboardTypeDefault;
    self.textField.text = self.text;
    
    // 显示模式兼容iOS7的ExtendedLayout模式
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.text = self.textField.text;
    self.textField.keyboardType = self.keyboardType;
    
    NSLog(@"发送文本保存事件");
    [[NSNotificationCenter defaultCenter] postNotificationName:kTextSavedMsg object:self userInfo:[NSDictionary dictionaryWithObject:self.text forKey:kTextSavedMsg]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end