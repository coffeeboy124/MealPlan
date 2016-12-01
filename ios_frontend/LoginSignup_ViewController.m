//
//  LoginSignup_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/3/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//


#import "LoginSignup_ViewController.h"

#define LOGIN_SEGUE_IDENTIFIER @"oLoginSegue"
#define SIGNUP_SEGUE_IDENTIFIER @"oSignupSegue"

@implementation LoginSignup_ViewController

@synthesize m_oServerHandler;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*NSString *sSavedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"];
    NSString *sSavedPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if(sSavedUsername != nil && sSavedPassword != nil){
        NSString *sPostData = [NSString stringWithFormat:@"user_name=%@&password=%@", sSavedUsername, sSavedPassword];
        m_oServerHandler = [[ServerHandler alloc] init];
        m_oServerHandler.m_oDelegate = self;
        [m_oServerHandler makeRequest:@"/user_action.php?action=Login" postData:sPostData action:@"Login"];
    }*/
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

#pragma mark Navigation

- (IBAction)unwindToLoginSignup:(UIStoryboardSegue *)segue {
    return;
}

#pragma mark Click Actions


- (IBAction)clickFacebook:(UIButton *)sender {
}

- (IBAction)clickGoogle:(UIButton *)sender {
}

- (IBAction)clickLogin:(UIButton *)sender {
    [self performSegueWithIdentifier:@"oLoginSegue" sender:nil];
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction{
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"])
    {
        UITabBarController *oTabBarController = [[UITabBarController alloc] init];
        [ThemeHandler initializeTabBar:oTabBarController];
        [self presentViewController:oTabBarController animated:YES completion:nil];
        return;
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError{
    return;
}

- (void)processJsonError:(NSError *)oError{
    return;
}
@end
