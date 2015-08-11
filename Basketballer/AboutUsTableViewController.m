//
//  AboutUsTableViewController.m
//  7MinutesWorkout
//
//  Created by sungeo on 15/8/7.
//  Copyright (c) 2015年 maoyu. All rights reserved.
//

#import "AboutUsTableViewController.h"

@interface AboutUsTableViewController ()

@end

@implementation AboutUsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.clearsSelectionOnViewWillAppear = YES;
    
    self.title = @"关于我们";
    
    // 读取App版本并显示
//    NSDictionary * info =[[NSBundle mainBundle] infoDictionary];
//    NSString * version = info[@"CFBundleShortVersionString"];
//    NSString * build = info[@"CFBundleVersion"];
//    self.versionLabel.text = [NSString stringWithFormat:@"v%@(%@)", version, build];
    self.versionLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * urls = @[@"http://weibo.com/iharbor",
                       @"http://weibo.com/imyelo",
                       @"http://weibo.com/maoyu417",
                       ];
    if (indexPath.row > urls.count - 1) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urls[indexPath.row]]];
}

@end
