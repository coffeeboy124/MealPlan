//
//  MyProfile_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/12/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "UserProfileModel.h"

@interface MyProfile_ViewController : UIViewController <ServerHandlerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (strong, nonatomic) UIImagePickerController *m_oImagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealsAttendedLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealsCreatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oMealFriendsLabel;

- (IBAction)clickMessage:(UIButton *)oButton;
- (IBAction)clickUploadPhoto:(UIButton *)oButton;

@end
