//
//  BCPlayGameViewController.h
//  Basketballer
//
//  Created by sungeo on 15/3/6.
//
//

#import <UIKit/UIKit.h>

@interface BCPlayGameViewController : UIViewController<UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIImageView * homeTeamHead;
@property (nonatomic, weak) IBOutlet UIImageView * guestTeamHead;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@end
