//
//  Yelp_TableViewCell.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Yelp_TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *m_oRatingImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oReviewsLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_oCheckButton;
@property (weak, nonatomic) IBOutlet UILabel *m_oMilesFromLocLabel;

@end
