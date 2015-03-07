//
//  SecondViewController.m
//  bascaptain
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCMyPlayersViewController.h"
#import "TeamManager.h"
#import "PlayerManager.h"
#import "BCMyPlayerListCell.h"
#import "NewPlayerViewController.h"

@interface BCMyPlayersViewController ()

@property (nonatomic, weak) Team * myTeam;
@property (nonatomic, strong) NSArray * players;

@end

@implementation BCMyPlayersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.myTeam = [[TeamManager defaultManager] myTeam];
    self.players = [[PlayerManager defaultManager] playersForTeam:self.myTeam.id];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myPlayerChanged:) name:kPlayerChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)myPlayerChanged:(NSNotification *)note{
    self.players = [[PlayerManager defaultManager] playersForTeam:self.myTeam.id];
    [self.tableView reloadData];
}

- (IBAction)addPlayer:(id)sender{
    NewPlayerViewController * vc = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
    vc.team = self.myTeam.id;
    vc.title = @"添加队员";
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.players.count;
 }

#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * sId = @"MyPlayerListCell";
    BCMyPlayerListCell * cell = [self.tableView dequeueReusableCellWithIdentifier:sId];
    [cell showPlayer:self.players[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewPlayerViewController * newPlayer = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
    newPlayer.model = [self.players objectAtIndex:indexPath.row];
    newPlayer.team = self.myTeam.id;
    [self.navigationController pushViewController:newPlayer animated:YES];
}

@end
