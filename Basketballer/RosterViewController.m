//
//  RRCollectionViewController.m
//  Basketballer
//
//  Created by sungeo on 14/11/7.
//
//

#import "RosterViewController.h"
#import "PlayerManager.h"
#import "ImageManager.h"
#import "RosterCollectionViewCell.h"
#import "NewPlayerViewController.h"
#import "AppDelegate.h"

#define kRosterCell         @"RosterCell"

@interface RosterViewController (){
    
    NSArray * _players;
    BOOL _removeMode;
}

@end

@implementation RosterViewController

- (NSString *)pageName {
    NSString * pageName = @"Roster";
    return pageName;
}

- (void)playerChangedNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:kPlayerChangedNotification]) {
        NSLog(@"收到队员更新消息");
        _players = [[PlayerManager defaultManager] playersForTeam:self.teamId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            //            [self.cv reloadData];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _players = [[PlayerManager defaultManager] playersForTeam:self.teamId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChangedNotification:) name:kPlayerChangedNotification object:nil];
    
    // 调用dequeueReusableCellWithReuseIdentifier之前注册自定义Cell Nib。
    // 由于是通过nib创建测cell，所以必须用这个接口注册，而不是registerClass:接口。
    [self.collectionView registerNib:[UINib nibWithNibName:@"RosterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kRosterCell];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // 除过所有队员外，还有“+”和“-”两个按钮。
    return (_players.count + 2);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RosterCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRosterCell forIndexPath:indexPath];
    
    NSInteger playerCount = _players.count;
    if (indexPath.row < playerCount) {
        Player * player = [_players objectAtIndex:indexPath.row];
        cell.name.text = player.name;
        cell.number.text = [player.number stringValue];
        
        UIImage * image = nil;
        if (player.profileURL != nil) {
            // 加载球员头像
            image = [[ImageManager defaultInstance] imageForName:player.profileURL];
        }else{
            image = [UIImage imageNamed:@"player_profile"];
        }
        cell.profile.image = image;
        cell.shadowView.hidden = NO;
        cell.removeView.hidden = ! _removeMode;
    }else if(indexPath.row == playerCount){
        cell.name.text = nil;
        cell.number.text = nil;
        cell.profile.image = [UIImage imageNamed:@"roster_add"];
        cell.shadowView.hidden = YES;
        cell.removeView.hidden = YES;
    }else if(indexPath.row == playerCount + 1){
        cell.name.text = nil;
        cell.number.text = nil;
        cell.profile.image = [UIImage imageNamed:@"roster_delete"];
        cell.shadowView.hidden = YES;
        cell.removeView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(76, 102);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, 50, 20);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger playerCount = _players.count;
    if (indexPath.row < playerCount) {
        if (! _removeMode) {
            NewPlayerViewController * vc = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
            vc.team = self.teamId;
            vc.model = [_players objectAtIndex:indexPath.row];
            vc.title = LocalString(@"EditPlayer");
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self removePlayer:[_players objectAtIndex:indexPath.row]];
        }
    }else if(indexPath.row == playerCount){
        // 添加队员
        NewPlayerViewController * vc = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
        vc.team = self.teamId;
        vc.title = LocalString(@"NewPlayer");
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == (playerCount + 1)){
        // 删除队员状态切换
        _removeMode = ! _removeMode;
        [self.collectionView reloadData];
        //        [self.cv reloadData];
    }
}

static Player * sPlayerToRemove = nil;
- (void)removePlayer:(Player *)player{
    sPlayerToRemove = player;
    NSString * messsage = [NSString stringWithFormat:@"remove player %@", player.name];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"RemovePlayer" message:messsage delegate:self cancelButtonTitle:LocalString(@"Cancel") otherButtonTitles:LocalString(@"Confirm"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 最终删除队员
        [[PlayerManager defaultManager] deletePlayer:sPlayerToRemove];
    }
}


//static NSString * const reuseIdentifier = @"Cell";
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // Uncomment the following line to preserve selection between presentations
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Register cell classes
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    
//    // Do any additional setup after loading the view.
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//#pragma mark <UICollectionViewDataSource>
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete method implementation -- Return the number of sections
//    return 0;
//}
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete method implementation -- Return the number of items in the section
//    return 0;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell
//    
//    return cell;
//}
//
//#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
