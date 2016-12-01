//
//  Invite_TableViewCell.h
//  Mealplan
//
//  Created by Mao on 7/7/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFriend_TableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *m_sToken;
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_oAcceptButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oRejectButton;

@end
