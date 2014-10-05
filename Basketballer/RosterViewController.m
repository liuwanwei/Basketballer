//
//  RosterViewController.m
//  Basketballer
//
//  Created by sungeo on 14-9-27.
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
}

@end

@implementation RosterViewController

- (void)playerChangedNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:kPlayerChangedNotification]) {
        NSLog(@"收到队员更新消息");
        _players = [[PlayerManager defaultManager] playersForTeam:self.teamId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cv reloadData];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _players = [[PlayerManager defaultManager] playersForTeam:self.teamId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerChangedNotification:) name:kPlayerChangedNotification object:nil];
    
    // 调用dequeueReusableCellWithReuseIdentifier之前注册自定义Cell Nib。
    // 由于是通过nib创建测cell，所以必须用这个接口注册，而不是registerClass:接口。
    [self.cv registerNib:[UINib nibWithNibName:@"RosterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kRosterCell];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    }else if(indexPath.row == playerCount){
        cell.name.text = nil;
        cell.number.text = nil;
        cell.profile.image = [UIImage imageNamed:@"roster_add"];
    }else if(indexPath.row == playerCount + 1){
        cell.name.text = nil;
        cell.number.text = nil;
        cell.profile.image = [UIImage imageNamed:@"roster_delete"];
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
        NewPlayerViewController * vc = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
        vc.team = self.teamId;
        vc.model = [_players objectAtIndex:indexPath.row];
        vc.title = LocalString(@"EditPlayer");
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == playerCount){
        // 添加队员
        NewPlayerViewController * vc = [[NewPlayerViewController alloc] initWithNibName:@"NewPlayerViewController" bundle:nil];
        vc.team = self.teamId;
        vc.title = LocalString(@"NewPlayer");
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == (playerCount + 1)){
        // TODO 删除队员
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
