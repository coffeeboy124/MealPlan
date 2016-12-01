//
//  LoginSignup_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/3/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Login_ViewController.h"
#import "Signup_ViewController.h"
#import "ServerHandler.h"
#import "ThemeHandler.h"

@interface LoginSignup_ViewController : UIViewController <ServerHandlerDelegate>

@property (strong, nonatomic) ServerHandler *m_oServerHandler;

- (IBAction)clickFacebook:(UIButton *)sender;
- (IBAction)clickGoogle:(UIButton *)sender;
- (IBAction)clickLogin:(UIButton *)sender;

@end
