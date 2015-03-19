//
//  BCGameStatisticsViewController.h
//  Basketballer
//
//  Created by sungeo on 15/3/11.
//
//

#import <UIKit/UIKit.h>

@interface BCGameStatisticsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView * tableViewPeroidCompare;
@property (nonatomic, weak) IBOutlet UITableView * tableViewPlayerCompare;

@end
