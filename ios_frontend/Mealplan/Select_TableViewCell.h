//
//  Select_TableViewCell.h
//  Mealplan
//
//  Created by Mao on 7/8/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Select_TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *m_oCheckButton;
@property (weak, nonatomic) IBOutlet UILabel *m_oUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oSublabel;

@end
