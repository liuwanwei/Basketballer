//
//  BCStatisticsTableViewController.h
//  Basketballer
//
//  Created by sungeo on 15/3/11.
//
//

#import <Foundation/Foundation.h>

@interface BCStatisticsTableViewController : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
