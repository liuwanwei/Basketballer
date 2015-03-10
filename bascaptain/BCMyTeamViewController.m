//
//  BCMyTeamViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/10.
//
//

#import "BCMyTeamViewController.h"
#import "TeamManager.h"
#import "PlayerManager.h"
#import "MatchManager.h"
#import "ImageManager.h"
#import "TextEditorFormViewController.h"

enum:NSInteger{
    IndexPathHeadImage = 0,
    IndexPathTeamName = 1,
    IndexPathPlayersCount,
    IndexPathMatchesCount
};

static NSString * const kTeamNameEditorKey = @"BCMyTeamViewControllerEditTeamName";

@interface BCMyTeamViewController ()
@property (nonatomic, weak) Team * myTeam;
@end

@implementation BCMyTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.myTeam = [TeamManager defaultManager].myTeam;
    
    CGFloat headImageWidth = self.imageViewHead.frame.size.width;
    self.imageViewHead.layer.cornerRadius = headImageWidth / 2;
    self.imageViewHead.clipsToBounds = YES;
    self.imageViewHead.layer.borderWidth = 1;
    self.imageViewHead.layer.borderColor = [[UIColor colorWithRed:140 green:221 blue:221 alpha:0.8] CGColor];
    
    self.imageViewHead.image = [[ImageManager defaultInstance] imageForName:self.myTeam.profileURL];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(teamNameModified:) name:kTextSavedMsg object:nil];
    [nc addObserver:self selector:@selector(teamChanged:) name:kTeamChanged object:nil];
    [nc addObserver:self selector:@selector(matchChanged:) name:kMatchChanged object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 球队信息更改响应消息，如修改比赛名字后
- (void)teamChanged:(NSNotification *)note{
    if (note.userInfo) {
        Team * changedTeam = note.userInfo[ChangedTeamObject];
        if (changedTeam && [changedTeam isEqual:self.myTeam]) {
            [self.tableView reloadData];
        }
    }
}

// 比赛信息更改响应消息，如删除比赛时
- (void)matchChanged:(NSNotification *)note{
    [self.tableView reloadData];
}

//#pragma mark - Table view data source

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * text = nil;
    NSInteger count;
    switch (indexPath.row) {
        case IndexPathTeamName:
            text = self.myTeam.name;
            break;
        case IndexPathPlayersCount:
            count = [[[PlayerManager defaultManager] playersForTeam:self.myTeam.id] count];
            text = [NSString stringWithFormat:@"%d人", (int)count];
            break;
        case IndexPathMatchesCount:
            count = [[[MatchManager defaultManager] matchesArray] count];
            text = [NSString stringWithFormat:@"%d场", (int)count];
            break;
        default:
            text = @"半点是个好地方";
            break;
    }
    
    cell.detailTextLabel.text = text;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == IndexPathTeamName) {
        // 打开文本编辑器修改球队名字
        TextEditorFormViewController * form = [[TextEditorFormViewController alloc] initWithTitle:@"球队名字"];
        form.textToEdit = self.myTeam.name;
        form.keyboardType = UIKeyboardTypeNamePhonePad;
        form.textKeyword = kTeamNameEditorKey;
        [self.navigationController pushViewController:form animated:YES];
        
    }else if(indexPath.row == IndexPathHeadImage){
        UIActionSheet * ac = [[UIActionSheet alloc] initWithTitle:@"修改球队照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
        [ac showInView:self.view];
        
    }else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

// 修改球队名字消息处理
- (void)teamNameModified:(NSNotification *)note{
    NSString * newName = note.userInfo[kTeamNameEditorKey];
    if (newName.length != 0) {
        [[TeamManager defaultManager] modifyTeam:self.myTeam withNewName:newName];
    }
}


#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        NSLog(@"拍照");
    }else if(buttonIndex == actionSheet.firstOtherButtonIndex + 1){
        NSLog(@"相册");
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
