//
//  BCPlayGameViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import "BCPlayGameViewController.h"
#import "BCActionTableController.h"

@interface BCPlayGameViewController ()
@property (nonatomic, strong) BCActionTableController * actionListController;
@end

@implementation BCPlayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 中间表格的创建和消息处理独立出来
    self.actionListController = [[BCActionTableController alloc] init];
    self.actionListController.tableView = self.tableView;
    self.actionListController.superViewController = self;
    
    // 隐藏多余的cell
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    [self initTeamsInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTeamsInfo{
    self.homeTeamHead.layer.cornerRadius = 18.0f;
    self.homeTeamHead.clipsToBounds = YES;
    self.guestTeamHead.layer.cornerRadius = 18.0f;
    self.guestTeamHead.clipsToBounds = YES;
}

- (IBAction)leftButtonClicked:(id)sender{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"结束比赛" otherButtonTitles:@"结束本节", @"比赛设置", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)timeControlButtonClicked:(id)sender{
    
}

- (IBAction)rightButtonClicked:(id)sender{
    
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
