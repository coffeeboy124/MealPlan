//
//  ViewProfile_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "UserProfileModel.h"

@interface ViewProfile_ViewController : UIViewController <ServerHandlerDelegate>

@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (strong, nonatomic) UserProfileModel *m_oUserProfileModel;
@property (strong, nonatomic) NSString *m_sSearchedUserName;
@property (strong, nonatomic) NSString *m_sBackSegue;
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oLocationLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_oMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oAddFriendButton;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealsAttendedLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealsCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oNotificationsLabel;

- (IBAction)clickBack:(UIButton *)sender;


@end
