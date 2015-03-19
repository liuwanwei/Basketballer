//
//  BCGameStatisticsViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/11.
//
//

#import "BCGameStatisticsViewController.h"
#import "BCStatisticsTableViewController.h"

@interface BCGameStatisticsViewController ()
@property (nonatomic, strong) BCStatisticsTableViewController * playerStatisticsController;
@end

@implementation BCGameStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewPeroidCompare.dataSource = self;
    self.tableViewPeroidCompare.delegate = self;
    
    // 队员技术统计界面数据由单独的类提供
    self.playerStatisticsController = [[BCStatisticsTableViewController alloc] initWithTableView:self.playerStatisticsController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

#pragma mark - Table view delegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
