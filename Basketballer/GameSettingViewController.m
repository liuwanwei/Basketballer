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
    NSArray * __weak _settingsArray;
    NSArray * __weak _settingsKeyArray;
    NSString * _header;
    
    NSArray * _groupHeaders;
    
    SingleChoiceViewController * _singleChoiceController;
}

@end

@implementation GameSettingViewController

@synthesize gameMode = _gameMode;
@synthesize viewStyle = _viewStyle;

- (void)initSettingsArray{
    GameSetting * gameSetting = [GameSetting defaultSetting];
    if([_gameMode isEqualToString:kGameModeFourQuarter]){
        _settingsArray = gameSetting.fourQuarterSettings;
        _settingsKeyArray = gameSetting.fourQuarterSettingsKey;
        _header = @"当选择四节模式开始比赛后，这些规则将会被自动使用：";
    }else if([_gameMode isEqualToString:kGameModeTwoHalf]){
        _settingsArray = gameSetting.twoHalfSettings;
        _settingsKeyArray = gameSetting.twoHalfSettingsKey;
        _header = @"当选择上下半场模式开始比赛后，这些规则将会被自动使用：";
    }else{
        _settingsArray = gameSetting.pointMatchSettings;
        _settingsKeyArray = gameSetting.pointMatchSettingsKey;
        _header = @"当选择抢分模式开始比赛后，这些规则将会被自动使用：";
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
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self initSettingsArray];
    
    // TODO 这个开销放这里是否必要？
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _settingsArray.count;
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

        if (_viewStyle == UIGameSettingViewStyleEdit) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;            
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
        }
    }
    
    // Configure the cell...
    cell.textLabel.text = [_settingsArray objectAtIndex:indexPath.row];
    
    NSString * parameterKey = [_settingsKeyArray objectAtIndex:indexPath.row];
    NSNumber * parameter = [[GameSetting defaultSetting] parameterForKey:parameterKey];
    NSString * parameterString = [parameter stringValue];
    parameterString = parameterString == nil ? @"0" : parameterString;
    NSString * parameterUnitString = [GameSetting unitStringForKey:parameterKey];
    
    UILabel * label = (UILabel *)[cell viewWithTag:ParamLabelTag];
    label.text = [NSString stringWithFormat:@"%@%@", parameterString, parameterUnitString];
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if(indexPath.section == 0 && _viewStyle == UIGameSettingViewStyleEdit){        
        NSString * parameterKey = [_settingsKeyArray objectAtIndex:indexPath.row];
        NSNumber * parameterValue = [[GameSetting defaultSetting] parameterForKey:parameterKey];
        NSString * unitString = [GameSetting unitStringForKey:parameterKey];
        NSArray * choices = [[GameSetting defaultSetting] choicesForKey:parameterKey];
        
        SingleChoiceViewController * controller = [self singleChoiceController];
        controller.parameterKey = parameterKey;
        controller.unitString = unitString;
        controller.currentChoice = [parameterValue stringValue];
        controller.choices = choices;
        [controller setTitle:[_settingsArray objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
