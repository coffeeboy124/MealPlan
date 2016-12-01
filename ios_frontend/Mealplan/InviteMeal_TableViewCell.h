//
//  InviteMeal_TableViewCell.h
//  Mealplan
//
//  Created by Mao on 10/9/15.
//  Copyright © 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteMeal_TableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *m_sToken;
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_oAcceptButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oRejectButton;

@end
