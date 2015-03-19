//
//  BCStatisticsTableViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/11.
//
//

#import "BCStatisticsTableViewController.h"

@interface BCStatisticsTableViewController()
@property (nonatomic, weak) UITableView * tableView;
@end

@implementation BCStatisticsTableViewController

- (instancetype)initWithTableView:(UITableView *)tableView{
    if (self = [super init]) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    
    return self;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * sId = @"TableView";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:sId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sId];
        cell.backgroundColor = [UIColor blueColor];
    }
    
    cell.textLabel.text = @"test";
}

@end
