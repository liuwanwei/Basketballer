//
//  RosterViewController.h
//  Basketballer
//
//  Created by sungeo on 14-9-27.
//
//

#import <UIKit/UIKit.h>

@interface RosterViewController : UIViewController<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView * cv;

@property (nonatomic, strong) NSNumber * teamId;


@end
