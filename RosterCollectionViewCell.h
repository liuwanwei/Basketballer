//
//  RosterCollectionViewCell.h
//  Basketballer
//
//  Created by sungeo on 14-9-27.
//
//

#import <UIKit/UIKit.h>

@interface RosterCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView * profile;
@property (nonatomic, weak) IBOutlet UILabel * name;
@property (nonatomic, weak) IBOutlet UILabel * number;

@end
