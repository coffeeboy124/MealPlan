//
//  TimeSheet_TableViewCell.h
//  Mealplan
//
//  Created by Mao on 7/28/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeSheet_TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *m_oNameField;
@property (weak, nonatomic) IBOutlet UIImageView *m_oIsActiveImage;
@property (weak, nonatomic) IBOutlet UIButton *m_oSetActiveButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oEditButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oRenameButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oDeleteButton;

@end
