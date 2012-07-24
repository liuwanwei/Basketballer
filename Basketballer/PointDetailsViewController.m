//
//  PointDetailsViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PointDetailsViewController.h"
#import "ActionManager.h"
#import "TeamManager.h"

@interface PointDetailsViewController (){
    NSArray * _homeTeamSummary;
    NSArray * _guestTeamSummary;
    
    NSArray * _statisticNames;
}

@end

@implementation PointDetailsViewController

@synthesize actions = _actions; // 一节中主客队的所有得分记录。
@synthesize match = _match;

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _statisticNames = [NSArray arrayWithObjects:@"三分", @"二分", @"一分", nil];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)summaryForFilter:(NSInteger)filter forTeam:(NSNumber *)teamId{
    NSInteger summary = 0;
    NSInteger intId = [teamId integerValue];
    for (Action * action in _actions) {
        NSInteger actionType = [action.type integerValue];
        if ([action.team integerValue] == intId && actionType == filter) {
            switch (actionType) {
                case ActionType1Point:
                    summary ++;
                    break;
                case ActionType2Points:
                    summary += 2;
                    break;
                case ActionType3Points:
                    summary += 3;
                    break;
                default:
                    break;
            }
        }
    }
    
    return [NSString stringWithFormat:@"%d", summary];
}

- (NSArray *)pointsSummaryForTeam:(NSNumber *)teamId{
    NSString * points;
    NSMutableArray * summary = [[NSMutableArray alloc] init];
    
    points = [self summaryForFilter:ActionType3Points forTeam:teamId];
    [summary addObject:points];
    
    points = [self summaryForFilter:ActionType2Points forTeam:teamId];
    [summary addObject:points];
    
    points = [self summaryForFilter:ActionType1Point forTeam:teamId];
    [summary addObject:points];
    
    return summary;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _homeTeamSummary = [self pointsSummaryForTeam:_match.homeTeam];
    _guestTeamSummary = [self pointsSummaryForTeam:_match.guestTeam];
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _homeTeamSummary.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [[TeamManager defaultManager] teamWithId:_match.homeTeam].name;
    }else{
        return [[TeamManager defaultManager] teamWithId:_match.guestTeam].name;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_statisticNames objectAtIndex:indexPath.row];
    
    if (0 == indexPath.section) {
        cell.detailTextLabel.text = [_homeTeamSummary objectAtIndex:indexPath.row];
    }else {
        cell.detailTextLabel.text = [_guestTeamSummary objectAtIndex:indexPath.row];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
