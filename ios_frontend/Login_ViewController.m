//
//  Login_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/4/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "Login_ViewController.h"

@implementation Login_ViewController

@synthesize m_oServerHandler;
@synthesize m_oUsernameField;
@synthesize m_oPasswordField;
@synthesize m_oErrorLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *oLoginView = [[[NSBundle mainBundle] loadNibNamed:@"Login" owner:self options:nil] firstObject];
    CGSize oLoginSize = self.view.bounds.size;
    oLoginView.frame = CGRectMake(0, 0, oLoginSize.width, oLoginSize.height);
    [self.view addSubview:oLoginView]; //loading from nib to fix ghost screen problem
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;
    
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_oUsernameField.delegate = self;
    m_oPasswordField.delegate = self;
    m_oPasswordField.secureTextEntry = YES;
    m_oUsernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    m_oPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    m_oUsernameField.tintColor = [UIColor blackColor];
    m_oPasswordField.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Navigation

- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue {
    return;
}

#pragma mark Click Actions

- (IBAction)clickLogin:(id)sender {
    if (!(m_oUsernameField.text && m_oUsernameField.text.length > 0 && m_oPasswordField.text && m_oPasswordField.text.length > 0))
    {
        m_oErrorLabel.text = @"Must enter username / password";
        return;
    }
    NSString *sPostData = [NSString stringWithFormat:@"user_name=%@&password=%@", m_oUsernameField.text, m_oPasswordField.text];
    
    [m_oServerHandler makeRequest:@"/user_action.php?action=Login" postData:sPostData action:@"Login"];
}

- (IBAction)clickSignup:(id)sender {
    [self performSegueWithIdentifier:@"oLoginSignupSegue" sender:nil];
}

- (void)clickBack {
    [self performSegueWithIdentifier:@"oBackSegue" sender:nil];
}

#pragma mark UITextFieldDelegate Protocol

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 32;
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if(![oServerResponseModel.m_sError isEqualToString:@"NULL"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            m_oErrorLabel.text = oServerResponseModel.m_sError;
        });
        return;
    }
    
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
        });
        NSUserDefaults *oUserDefaults = [NSUserDefaults standardUserDefaults];
        [oUserDefaults setObject:m_oUsernameField.text forKey:@"user_name"];
        [oUserDefaults setObject:m_oPasswordField.text forKey:@"password"];
        [oUserDefaults synchronize];
        
        UITabBarController *oTabBarController = [[UITabBarController alloc] init];
        [ThemeHandler initializeTabBar:oTabBarController];
        [self presentViewController:oTabBarController animated:YES completion:nil];
        return;
        
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
