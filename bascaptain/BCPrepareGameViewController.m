//
//  PrepareGameViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/7.
//
//

#import "BCPrepareGameViewController.h"
#import "BCPlayGameViewController.h"
#import "TeamManager.h"
#import <XLForm.h>

NSString * const kOpponentNameRow = @"OpponentNameRow";

@interface BCPrepareGameViewController ()

@end

@implementation BCPrepareGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = item;
    
    item = [[UIBarButtonItem alloc] initWithTitle:@"开始" style:UIBarButtonItemStyleDone target:self action:@selector(enterGame:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init{
    if (self = [super init]) {
        [self createForm];
    }
    
    return self;
}

- (void)createForm{
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:@"开始比赛"];
    self.form = form;
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:kOpponentNameRow rowType:XLFormRowDescriptorTypeText title:@"对手名字："];
    row.value = @"test";// FIXME
    [section addFormRow:row];
    
//    section = [XLFormSectionDescriptor formSection];
//    [form addFormSection:section];
//    
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton title:@"进入比赛"];
//    row.action.formSelector = @selector(enterGame:);
//    [section addFormRow:row];
}

- (void)enterGame:(id)sender{
    NSString * opponent = [self.form formRowWithTag:kOpponentNameRow].value;
    if (opponent.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"请输入球队名字"
                                    message:@"对手球队名字不能为空" delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil, nil] show];
         return;
    }
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    BCPlayGameViewController * vc = [sb instantiateViewControllerWithIdentifier:@"BCPlayGameViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.hostTeam = [[TeamManager defaultManager] myTeam];
    vc.guestTeam = [[TeamManager defaultManager] newTeam:opponent withImage:[UIImage imageNamed:@"DefaultGuestTeam"]];
    [self.navigationController pushViewController:vc animated:YES];
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
