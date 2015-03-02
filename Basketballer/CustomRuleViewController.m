//
//  CustomRuleViewController.m
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import "CustomRuleViewController.h"
#import "FibaCustomRule.h"
#import "CustomRuleManager.h"
#import "AppDelegate.h"
#import "TextEditorFormViewController.h"

#define checkSetValue(property)   ((property != nil) && ([property integerValue] != 0))

@interface CustomRuleViewController ()

@property (nonatomic, strong) NSIndexPath * lastChoosedIndexPath;
@property (nonatomic, strong) FibaCustomRule * createdcustomRule;

@end

@implementation CustomRuleViewController

- (void)checkAllParametersSupplied{
    if (self.customRule != nil &&
        self.customRule.name != nil &&
        checkSetValue(self.customRule.periodTimeLength) &&
        checkSetValue(self.customRule.periodRestTimeLength) &&
        checkSetValue(self.customRule.halfTimeRestTimeLength) &&
        checkSetValue(self.customRule.overTimeLength)){
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)save{
    // 保存比赛规则
    [[CustomRuleManager defaultInstance] customRuleWithFibaRule:self.customRule];
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRuleChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.createMode) {
        // 新建时，需要用strong类型的指针指向要创建的自定义规则
        self.createdcustomRule = [[FibaCustomRule alloc] init];
        self.customRule = self.createdcustomRule;
    }
    
    self.title = LocalString(@"Custom");
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    [self checkAllParametersSupplied];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textSavedNotification:) name:kTextSavedMsg object:nil];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return 4;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"单位：分钟";
    }else{
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * sIdentifier = @"CustomRuleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = LocalString(@"RuleName");
        cell.detailTextLabel.text = self.customRule.name;
    }else if(indexPath.section == 1){
        NSString * labelText = nil;
        NSString * detailText = nil;
        switch (indexPath.row) {
            case 0:
                labelText = LocalString(@"PeriodLength");
                detailText = [self.customRule.periodTimeLength stringValue];
                break;
            case 1:
                labelText = LocalString(@"PeriodIntervalLength");
                detailText = [self.customRule.periodRestTimeLength stringValue];
                break;
            case 2:
                labelText = LocalString(@"HalfTimeIntervalLength");
                detailText = [self.customRule.halfTimeRestTimeLength stringValue];
                break;
            case 3:
                labelText = LocalString(@"ExtraPeriodLength");
                detailText = [self.customRule.overTimeLength stringValue];
                break;
            default:
                break;
        }
        
        cell.textLabel.text = labelText;
        cell.detailTextLabel.text = detailText;
    }
    
    return cell;
}

// 文本编辑器消息处理
- (void)textSavedNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:kTextSavedMsg]) {
        NSString * text = [notification.userInfo objectForKey:kTextSavedMsg];
        if (nil != text) {
            
            if (_lastChoosedIndexPath.section == 0) {
                // 修改了名字
                self.customRule.name = text;
            }else if(_lastChoosedIndexPath.section == 1){
                NSNumber * value = [NSNumber numberWithInteger:[text integerValue]];
                switch (_lastChoosedIndexPath.row) {
                    case 0:
                        self.customRule.periodTimeLength = value;
                        break;
                    case 1:
                        self.customRule.periodRestTimeLength = value;
                        break;
                    case 2:
                        self.customRule.halfTimeRestTimeLength = value;
                        break;
                    case 3:
                        self.customRule.overTimeLength = value;
                        break;
                    default:
                        break;
                }
            }
            
            // 刷新修改过的Cell详情
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:_lastChoosedIndexPath];
                cell.detailTextLabel.text = text;
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_lastChoosedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
            
            // 输入完毕后检查是否打开导航栏右侧“保存”按钮
            [self checkAllParametersSupplied];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _lastChoosedIndexPath = indexPath;
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    TextEditorFormViewController * vc = [[TextEditorFormViewController alloc] initWithTitle:cell.textLabel.text];
    
    vc.textToEdit = cell.detailTextLabel.text;
    
    if (indexPath.section == 0) {
        vc.keyboardType = UIKeyboardTypeNamePhonePad;
    }else{
        vc.keyboardType = UIKeyboardTypeNumberPad;
    }

    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
