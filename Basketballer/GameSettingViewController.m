//
//  GameSettingViewControllerViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameSettingViewController.h"
#import "SingleChoiceViewController.h"
#import "GameSetting.h"
#import "AppDelegate.h"

@interface GameSettingViewController (){
    NSMutableArray * _settings;
    NSArray * _header;
    NSArray * _mode;
    NSArray * _twoHalfSettings;
    NSArray * _twoHalfSettingsKey;
    NSArray * _fourQuarterSettings;
    NSArray * _fourQuarterSettingsKey;
    
    SingleChoiceViewController * _singleChoiceController;
    NSIndexPath * _enteredSetting;
}

@end

@implementation GameSettingViewController

- (NSArray *)settingsArray{
    if([[[GameSetting defaultSetting] mode] isEqualToString:kGameModeFourQuarter]){
        return _fourQuarterSettings;
    }else{
        return _twoHalfSettings;
    }    
}

- (NSArray *)settingKeysArray{
    if([[[GameSetting defaultSetting] mode] isEqualToString:kGameModeFourQuarter]){
        return _fourQuarterSettingsKey;
    }else{
        return _twoHalfSettingsKey;
    }
}

- (SingleChoiceViewController *)singleChoiceController{
    if (_singleChoiceController == nil) {
        _singleChoiceController = [[SingleChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    
    return _singleChoiceController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _header = [NSArray arrayWithObjects:@"比赛模式", @"技术参数", nil];
        
        _mode = [NSArray arrayWithObjects:@"上下半场", @"四节", nil];
        
        // Two half mode settings and the keywords used to store the settings.
        _twoHalfSettings = [NSArray arrayWithObjects:@"半场时间", 
                                                     @"中场休息时间", 
                                                     @"半场犯规罚球次数", 
                                                     @"允许暂停次数", 
                                                     @"暂停时间", nil];
        _twoHalfSettingsKey = [NSArray arrayWithObjects:kGameHalfLength, 
                                                        kGameHalfTimeLength, 
                                                        kGameFoulsOverHalfLimit, 
                                                        kGameTimeoutsOverHalfLimit, 
                                                        kGameTimeoutLength, nil];
        
        _fourQuarterSettings = [NSArray arrayWithObjects:@"单节时间", 
                                                         @"节间休息时间", 
                                                         @"中场休息时间", 
                                                         @"单节犯规罚球次数", 
                                                         @"允许暂停次数", 
                                                         @"暂停时间", nil];
        _fourQuarterSettingsKey = [NSArray arrayWithObjects:kGameQuarterLength, 
                                                            kGameQuarterTimeLength, 
                                                            kGameHalfTimeLength, 
                                                            kGameFoulsOverQuarterLimit, 
                                                            kGameTimeoutsOverQuarterLimit, 
                                                            kGameTimeoutLength, nil];
        
    }
    return self;
}

- (void)dismissMyself{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    [delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissMyself)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    // TODO move to string file.
    [self setTitle:@"比赛设置"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_enteredSetting != nil) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_enteredSetting] withRowAnimation:UITableViewRowAnimationAutomatic];
        _enteredSetting = nil;  // TODO do I need to release object obtained by copy message?
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [_mode count];
    }else {
        return  [[self settingsArray] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    const NSInteger ParamLabelTag = 1000;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(110, cell.textLabel.frame.origin.y, 170.f, tableView.rowHeight)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        [label setTag:ParamLabelTag];
        
        [cell addSubview:label];
        [cell.superview bringSubviewToFront:label];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = [_mode objectAtIndex:indexPath.row];
        NSInteger selectedMode = [[[GameSetting defaultSetting] mode] isEqualToString:kGameModeFourQuarter] ? 1 : 0;
        
        if (indexPath.row == selectedMode) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else if(indexPath.section == 1){
        cell.textLabel.text = [[self settingsArray] objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSString * parameterKey = [[self settingKeysArray] objectAtIndex:indexPath.row];
        NSNumber * parameter = [[GameSetting defaultSetting] parameterForKey:parameterKey];
        NSString * parameterString = [parameter stringValue];
        parameterString = parameterString == nil ? @"0" : parameterString;
        NSString * parameterUnitString = [GameSetting unitStringForKey:parameterKey];
        
        UILabel * label = (UILabel *)[cell viewWithTag:ParamLabelTag];
        label.text = [NSString stringWithFormat:@"%@%@", parameterString, parameterUnitString];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        NSString * mode = (indexPath.row == 0 ? kGameModeTwoHalf : kGameModeFourQuarter);
        [[GameSetting defaultSetting] setParameter:mode forKey:kGameMode]; 
        [self.tableView reloadData];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if(indexPath.section == 1){        
        NSString * parameterKey = [[self settingKeysArray] objectAtIndex:indexPath.row];
        NSNumber * parameterValue = [[GameSetting defaultSetting] parameterForKey:parameterKey];
        NSString * unitString = [GameSetting unitStringForKey:parameterKey];
        NSArray * choices = [[GameSetting defaultSetting] choicesForKey:parameterKey];
        
        SingleChoiceViewController * controller = [self singleChoiceController];
        controller.parameterKey = parameterKey;
        controller.unitString = unitString;
        controller.currentChoice = [parameterValue stringValue];
        controller.choices = choices;
        [controller setTitle:[[self settingsArray] objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:controller animated:YES];
        _enteredSetting = [indexPath copy];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_header objectAtIndex:section];
}

@end
