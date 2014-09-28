//
//  RosterViewController.h
//  Basketballer
//
//  Created by sungeo on 14-9-27.
//
//

#import <UIKit/UIKit.h>

@interface RosterViewController : UIViewController<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView * cv;

@property (nonatomic, strong) NSNumber * teamId;
@property (nonatomic, strong) NSArray * players;


@end
