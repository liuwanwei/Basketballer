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
#import "TextEditorViewController.h"

#define checkSetValue(property)   ((property != nil) && ([property integerValue] != 0))

@interface CustomRuleViewController (){
    NSIndexPath * _lastChoosedIndexPath;
}

@end

@implementation CustomRuleViewController

- (BOOL)allParameterSupplied{
    if (self.rule != nil &&
        self.rule.name != nil &&
        checkSetValue(self.rule.periodTimeLength) &&
        checkSetValue(self.rule.periodRestTimeLength) &&
        checkSetValue(self.rule.halfTimeRestTimeLength) &&
        checkSetValue(self.rule.overTimeLength)){
        return true;
    }else{
        return false;
    }
}

- (void)save{
    
    // 保存比赛规则
    [[CustomRuleManager defaultInstance] customRuleWithFibaRule:self.rule];
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRuleChangedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LocalString(@"Custom");
    self.clearsSelectionOnViewWillAppear = NO;
    
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
        cell.detailTextLabel.text = self.rule.name;
    }else if(indexPath.section == 1){
        NSString * labelText = nil;
        NSString * detailText = nil;
        switch (indexPath.row) {
            case 0:
                labelText = LocalString(@"PeriodLength");
                detailText = [self.rule.periodTimeLength stringValue];
                break;
            case 1:
                labelText = LocalString(@"PeriodIntervalLength");
                detailText = [self.rule.periodRestTimeLength stringValue];
                break;
            case 2:
                labelText = LocalString(@"HalfTimeIntervalLength");
                detailText = [self.rule.halfTimeRestTimeLength stringValue];
                break;
            case 3:
                labelText = LocalString(@"ExtraPeriodLength");
                detailText = [self.rule.overTimeLength stringValue];
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
            if (self.rule == nil) {
                self.rule = [[FibaCustomRule alloc] init];
            }
            
            if (_lastChoosedIndexPath.section == 0) {
                // 修改了名字
                self.rule.name = text;
            }else if(_lastChoosedIndexPath.section == 1){
                NSNumber * value = [NSNumber numberWithInteger:[text integerValue]];
                switch (_lastChoosedIndexPath.row) {
                    case 0:
                        self.rule.periodTimeLength = value;
                        break;
                    case 1:
                        self.rule.periodRestTimeLength = value;
                        break;
                    case 2:
                        self.rule.halfTimeRestTimeLength = value;
                        break;
                    case 3:
                        self.rule.overTimeLength = value;
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
            
            // 输入完毕后导航栏右侧“保存”按钮
            if ([self allParameterSupplied]) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
            }else{
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _lastChoosedIndexPath = indexPath;
    
    TextEditorViewController * vc = [[TextEditorViewController alloc] initWithNibName:@"TextEditorViewController" bundle:nil];
    
    if (indexPath.section == 0) {
        vc.keyboardType = UIKeyboardTypeNamePhonePad;
    }else{
        vc.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.text = cell.detailTextLabel.text;
    vc.title = cell.textLabel.text;
    
    [self.navigationController pushViewController:vc animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
