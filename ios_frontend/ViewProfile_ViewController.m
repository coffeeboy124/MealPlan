//
//  ViewProfile_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "ViewProfile_ViewController.h"

@implementation ViewProfile_ViewController

@synthesize m_oServerHandler;
@synthesize m_oUserProfileModel;
@synthesize m_sSearchedUserName;
@synthesize m_sBackSegue;
@synthesize m_oProfileImage;
@synthesize m_oUserNameLabel;
@synthesize m_oLocationLabel;
@synthesize m_oMessageButton;
@synthesize m_oAddFriendButton;
@synthesize m_oMealFriendsLabel;
@synthesize m_oMealsAttendedLabel;
@synthesize m_oMealsCreatedLabel;
@synthesize m_oNotificationsLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oServerHandler.m_oDelegate = self;
}

- (void) viewDidAppear:(BOOL)animated {
    NSString *sViewProfileUrl = [NSString stringWithFormat:@"/user_action.php?action=ViewProfile&user_name=%@", m_sSearchedUserName];
    [m_oServerHandler makeRequest:sViewProfileUrl postData:nil action:@"ViewProfile"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark Click Actions

- (IBAction)clickBack:(UIButton *)sender {
    [self performSegueWithIdentifier:m_sBackSegue sender:nil];
}

- (void)clickAddFriend {
    NSString *sViewProfileUrl = [NSString stringWithFormat:@"/relation_action.php?action=CreateRelation&user_name=%@", m_sSearchedUserName];
    [m_oServerHandler makeRequest:sViewProfileUrl postData:nil action:@"CreateRelation"];
}

- (void)clickMessage{
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ViewProfile"])
    {
        NSError *oJsonError;
        m_oUserProfileModel = [[UserProfileModel alloc] initWithString:oServerResponseModel.m_sOutput error:&oJsonError];

        if(oJsonError)
        {
            NSLog(@"json error: %@", oJsonError.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], m_oUserProfileModel.m_sUserPic]];
            UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
            [m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
            m_oProfileImage.contentMode = UIViewContentModeScaleAspectFill;
            m_oProfileImage.layer.cornerRadius = m_oProfileImage.frame.size.width / 2;
            m_oProfileImage.clipsToBounds = YES;
            
            m_oUserNameLabel.text = m_oUserProfileModel.m_sName;
            m_oUserNameLabel.text = m_oUserProfileModel.m_sUserName;
            m_oMealsCreatedLabel.text = [NSString stringWithFormat:@"%i", m_oUserProfileModel.m_iNumberMealsCreated];
            m_oMealsAttendedLabel.text = [NSString stringWithFormat:@"%i", m_oUserProfileModel.m_iNumberMealsAttended];
            m_oMealFriendsLabel.text = [NSString stringWithFormat:@"%i", m_oUserProfileModel.m_iNumberFriends];
            
            if([m_oUserProfileModel.m_sIsFriend isEqualToString:@"YES"])
            {
                m_oAddFriendButton.alpha = 0.4;
                m_oAddFriendButton.enabled = NO;
                [m_oMessageButton addTarget:self action:@selector(clickMessage) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([m_oUserProfileModel.m_sIsFriend isEqual:@"PENDING"])
            {
                m_oAddFriendButton.alpha = 0.4;
                m_oAddFriendButton.enabled = NO;
                m_oNotificationsLabel.text = @"Invite Sent!";
            }
            else
            {
                [m_oAddFriendButton addTarget:self action:@selector(clickAddFriend) forControlEvents:UIControlEventTouchUpInside];
            }
        });
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"FALSE"] && [sAction isEqualToString:@"ViewProfile"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_oUserNameLabel.text = @"User not found!";
        });
    }
    else if([sAction isEqualToString:@"CreateRelation"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_oAddFriendButton.alpha = 0.4;
            m_oAddFriendButton.enabled = NO;
            m_oNotificationsLabel.text = @"Invite Sent!";
        });
    }
    
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

@end
