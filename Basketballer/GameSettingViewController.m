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
    NSArray * _header;
    NSArray * _modeString;
    
    NSArray * _twoHalfSettings;
    NSArray * _twoHalfSettingsKey;
    NSArray * _fourQuarterSettings;
    NSArray * _fourQuarterSettingsKey;
    
    NSArray * __weak _settingsArray;
    NSArray * __weak _settingsKeyArray;
    
    NSArray * _groupHeaders;
    
    SingleChoiceViewController * _singleChoiceController;
}

@end

@implementation GameSettingViewController

@synthesize gameMode = _gameMode;

- (void)initSettingsArray{
    if([_gameMode isEqualToString:kGameModeFourQuarter]){
        _settingsArray = _fourQuarterSettings;
        _settingsKeyArray = _fourQuarterSettingsKey;
    }else{
        _settingsArray = _twoHalfSettings;
        _settingsKeyArray = _twoHalfSettingsKey;
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
        
        _modeString = [NSArray arrayWithObjects:@"上下半场", @"四节", nil];
        
        // Two half mode settings and the keywords used to store the settings.
        _twoHalfSettings = [NSArray arrayWithObjects:@"半场比赛时间", 
                                                     @"中场休息时间", 
                                                     @"球队最大犯规次数", 
                                                     @"半场允许暂停次数", 
                                                     @"暂停时间", nil];
        _twoHalfSettingsKey = [NSArray arrayWithObjects:kGameHalfLength, 
                                                        kGameHalfTimeLength, 
                                                        kGameFoulsOverHalfLimit, 
                                                        kGameTimeoutsOverHalfLimit, 
                                                        kGameTimeoutLength, nil];
        
        _fourQuarterSettings = [NSArray arrayWithObjects:@"单节比赛时间", 
                                                         @"节间休息时间", 
                                                         @"中场休息时间", 
                                                         @"球队最大犯规次数", 
                                                         @"单节允许暂停次数", 
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
    [self.tableView reloadData];
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
    }
    
    // Configure the cell...
    cell.textLabel.text = [_settingsArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    if(indexPath.section == 0){        
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
