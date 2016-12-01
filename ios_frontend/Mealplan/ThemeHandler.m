//
//  ThemeHandler.m
//  Mealplan
//
//  Created by Mao on 7/7/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "ThemeHandler.h"

@implementation ThemeHandler

+ (void)initializeTabBar:(UITabBarController *)oTabBarController{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard* oMainMenuStoryboard = [UIStoryboard storyboardWithName:@"MainMenu" bundle:nil];
        UINavigationController * oMainMenuViewController = [oMainMenuStoryboard instantiateInitialViewController];
        oMainMenuViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"icon_home.png"] tag:0];
        
        UIStoryboard* oMyFriendsStoryboard = [UIStoryboard storyboardWithName:@"MyFriends" bundle:nil];
        UIViewController* oMyFriendsViewController = [oMyFriendsStoryboard instantiateInitialViewController];
        oMyFriendsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"icon_friends.png"] tag:1];
        
        UIStoryboard* oMyProfileStoryboard = [UIStoryboard storyboardWithName:@"MyProfile" bundle:nil];
        UIViewController* oMyProfileViewController = [oMyProfileStoryboard instantiateInitialViewController];
        oMyProfileViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"icon_profile.png"] tag:2];
        
        UIStoryboard* oTimeSheetsStoryboard = [UIStoryboard storyboardWithName:@"TimeSheets" bundle:nil];
        UINavigationController * oTimeSheetsViewController = [oTimeSheetsStoryboard instantiateInitialViewController];
        oTimeSheetsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Meal Times" image:[UIImage imageNamed:@"icon_schedule.png"] tag:3];
        
        [oTabBarController setViewControllers:@[oMainMenuViewController, oMyFriendsViewController, oMyProfileViewController, oTimeSheetsViewController]];
    });
    
    return;
}

+ (void)initializeNavBar {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"icon_back.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"icon_back.png"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewDidLoad {
}


@end
