//
//  AppRecommandationViewController.m
//  7MinutesWorkout
//
//  Created by sungeo on 15/8/7.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "AppRecommandationViewController.h"

@interface AppRecommandationViewController ()

@end

@implementation AppRecommandationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"客官请慢用";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * urls = @[
                       @"itms-apps://itunes.apple.com/app/id995154169",
                       @"itms-apps://itunes.apple.com/app/id1019382088",
                       @"itms-apps://itunes.apple.com/app/id1013694558",
                       ];
    
    if (indexPath.row > urls.count - 1) {
        return;
    }
    
    // TODO: 增加应用推荐点击统计
    NSURL * url = [NSURL URLWithString:urls[indexPath.row]];
    // 须知：这种方式在模拟器下没有反应，在真机下能直接打开链接
    [[UIApplication sharedApplication] openURL:url];
    NSLog(@"open url: %@", url);
}

@end
