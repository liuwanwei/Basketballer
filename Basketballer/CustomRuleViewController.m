//
//  CustomRuleViewController.m
//  Basketballer
//
//  Created by sungeo on 14-9-30.
//
//

#import "CustomRuleViewController.h"
#import "FibaCustomRule.h"
#import "AppDelegate.h"
#import "TextEditorViewController.h"

@interface CustomRuleViewController (){
    NSIndexPath * _lastChoosedIndexPath;
}

@end

@implementation CustomRuleViewController

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * sIdentifier = @"CustomRuleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = LocalString(@"NewName");
    }else if(indexPath.section == 1){
        NSString * labelText = nil;
        switch (indexPath.row) {
            case 0:
                labelText = LocalString(@"PeriodLength");
                break;
            case 1:
                labelText = LocalString(@"PeriodIntervalLength");
                break;
            case 2:
                labelText = LocalString(@"HalfTimeIntervalLength");
                break;
            case 3:
                labelText = LocalString(@"ExtraPeriodLength");
                break;
            default:
                break;
        }
        
        cell.textLabel.text = labelText;
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
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _lastChoosedIndexPath = indexPath;
    
    TextEditorViewController * vc = [[TextEditorViewController alloc] initWithNibName:@"TextEditorViewController" bundle:nil];
    
    if (indexPath.section == 0) {
        vc.keyboardType = UIKeyboardTypeNumberPad;
    }else{
        vc.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.text = cell.detailTextLabel.text;
    
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
