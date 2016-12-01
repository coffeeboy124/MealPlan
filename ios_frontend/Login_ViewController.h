//
//  Login_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/4/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerHandler.h"
#import "ServerResponseModel.h"
#import "ThemeHandler.h"

@interface Login_ViewController : UIViewController <UITextFieldDelegate, ServerHandlerDelegate>

@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (weak, nonatomic) IBOutlet UITextField *m_oUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *m_oPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *m_oErrorLabel;

- (IBAction)clickLogin:(id)sender;
- (IBAction)clickSignup:(id)sender;

@end


