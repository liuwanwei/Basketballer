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
#import "Feature.h"

typedef enum {
    GameModeTwoHalf = 0,
    GameModeFourQuarter = 1,
    GameModePoints = 2
}GameMode;

@interface GameSettingViewController (){
    SingleChoiceViewController * _singleChoiceController;
}

@end

@implementation GameSettingViewController

@synthesize gameMode = _gameMode;
@synthesize viewStyle = _viewStyle;
@synthesize settingsArray = _settingsArray;
@synthesize settingsKeyArray = _settingsKeyArray;

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initTitle {
    NSArray * modes = [[GameSetting defaultSetting] gameModeNames];

    if ([_gameMode isEqualToString:kGameModeTwoHalf]) {
        [self setTitle:[modes objectAtIndex:GameModeTwoHalf]];
    }else if ([_gameMode isEqualToString:kGameModeFourQuarter]) {
        [self setTitle:[modes objectAtIndex:GameModeFourQuarter]];
    }else {
        [self setTitle:[modes objectAtIndex:GameModePoints]];
    }
}

- (void)initSettingsArray{
    GameSetting * gameSetting = [GameSetting defaultSetting];
    if([_gameMode isEqualToString:kGameModeFourQuarter]){
        _settingsArray = gameSetting.fourQuarterSettings;
        _settingsKeyArray = gameSetting.fourQuarterSettingsKey;
    }else if([_gameMode isEqualToString:kGameModeTwoHalf]){
        _settingsArray = gameSetting.twoHalfSettings;
        _settingsKeyArray = gameSetting.twoHalfSettingsKey;
    }else{
        _settingsArray = gameSetting.pointMatchSettings;
        _settingsKeyArray = gameSetting.pointMatchSettingsKey;
    }
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
    [self initTitle];
    [[Feature defaultFeature] initNavleftBarItemWithController:self withAction:@selector(back)];
    // TODO 这个开销放这里是否必要？
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
        return 0;
    }
    return  _settingsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (1 == section) {
        if(self.viewStyle != GameSettingViewStyleShow) {
            return @"规则：";
        }else if(self.viewStyle == GameSettingViewStyleShow){
            return @"规则：（比赛开始后不能修改规则）";
        }
    }
    return nil;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    static NSString *CellIdentifier = @"Cell";
    const NSInteger ParamLabelTag = 1000;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
        
        if (_viewStyle == GameSettingViewStyleEdit) {
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if(indexPath.section == 1 && _viewStyle == GameSettingViewStyleEdit){        
        NSString * parameterKey = [_settingsKeyArray objectAtIndex:indexPath.row];
        NSNumber * parameterValue = [[GameSetting defaultSetting] parameterForKey:parameterKey];
        NSString * unitString = [GameSetting unitStringForKey:parameterKey];
        NSArray * choices = [[GameSetting defaultSetting] choicesForKey:parameterKey];
        
        SingleChoiceViewController * controller = [[SingleChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.parameterKey = parameterKey;
        controller.unitString = unitString;
        controller.currentChoice = [parameterValue stringValue];
        controller.choices = choices;
        [controller setTitle:[_settingsArray objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
