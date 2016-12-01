//
//  MealSummary_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/12/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MealSummary_ViewController.h"

@implementation MealSummary_ViewController

@synthesize m_oCurrentMealUserModels;
@synthesize m_oInvitedMealUserModels;
@synthesize m_oCurrentMealUserModel;
@synthesize m_bIsCurrentSectionOpen;
@synthesize m_bIsInvitedSectionOpen;
@synthesize m_bIsHost;
@synthesize m_sToken;
@synthesize m_sMealName;
@synthesize m_oServerHandler;
@synthesize m_oTableView;
@synthesize m_oTimeButton;
@synthesize m_oVoteButton;
@synthesize m_oMealNameField;
@synthesize m_oMealStateModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"icon_back.png"];
    
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;

    m_oCurrentMealUserModels = [[NSMutableArray alloc] init];
    m_oInvitedMealUserModels = [[NSMutableArray alloc] init];
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    m_oTableView.backgroundColor = [UIColor clearColor];
    m_oServerHandler.m_oDelegate = self;
    m_oMealNameField.delegate = self;
    m_oMealNameField.text = m_sMealName;
    self.title = @"Meal Summary";
    m_oTimeButton.enabled = YES;
    m_oVoteButton.enabled = YES;
    m_oVoteButton.tag = 0;
    
    [m_oTimeButton addTarget:self action:@selector(clickChooseTime) forControlEvents:UIControlEventTouchUpInside];
    [m_oVoteButton addTarget:self action:@selector(clickVoteRestaurant) forControlEvents:UIControlEventTouchUpInside];
    
    UINib *oPersonCellNib = [UINib nibWithNibName:@"Person_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oPersonCellNib forCellReuseIdentifier:@"Person_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void) viewDidAppear:(BOOL)animated {
    m_bIsCurrentSectionOpen = YES;
    m_bIsInvitedSectionOpen = YES;
    
    NSString *sViewMealUsersUrl = [NSString stringWithFormat:@"/meal_action.php?action=ViewMealUsers&token=%@", m_sToken];
    [m_oServerHandler makeRequest:sViewMealUsersUrl postData:nil action:@"ViewMealUsers"];
    NSString *sViewMealStateUrl = [NSString stringWithFormat:@"/meal_action.php?action=ViewMealState&token=%@", m_sToken];
    [m_oServerHandler makeRequest:sViewMealStateUrl postData:nil action:@"ViewMealState"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((int) section == 0)
    {
        if(m_bIsCurrentSectionOpen)
            return m_oCurrentMealUserModels.count;
        else
            return 0;
    }
    else
    {
        if(m_bIsInvitedSectionOpen)
            return m_oInvitedMealUserModels.count;
        else
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Person_TableViewCell *oPersonCell = [tableView dequeueReusableCellWithIdentifier:@"Person_TableViewCell"];
    if(!oPersonCell)
        oPersonCell = [[Person_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Person_TableViewCell"];
    
    MealUserModel *oMealUserModel;
    if(indexPath.section == 0)
        oMealUserModel = m_oCurrentMealUserModels[indexPath.row];
    else
        oMealUserModel = m_oInvitedMealUserModels[indexPath.row];
    
    NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oMealUserModel.m_sUserPic]];
    UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
    [oPersonCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
    
    oPersonCell.m_oUserNameLabel.text = oMealUserModel.m_sUserName;
    oPersonCell.m_oButton.hidden = YES;
    oPersonCell.m_oSubLabel.hidden = YES;
    oPersonCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return oPersonCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    
    oSectionHeaderView.m_oDelegate = self;
    oSectionHeaderView.m_iSection = section;
    
    if(section == 0)
        oSectionHeaderView.m_oNameLabel.text = @"Current Guests";
    else
        oSectionHeaderView.m_oNameLabel.text = @"Invited";
    
    oSectionHeaderView.m_oIconImage.hidden = YES;
    return oSectionHeaderView;
}

#pragma mark UITableViewDataDelegate Protocol

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        m_oCurrentMealUserModel = m_oCurrentMealUserModels[indexPath.row];
    else
        m_oCurrentMealUserModel = m_oInvitedMealUserModels[indexPath.row];
    [self performSegueWithIdentifier:@"oMealSummaryViewProfileSegue" sender:nil];
}

#pragma mark Helper Methods

- (UIView *)viewWithImageName:(NSString *)sImageName {
    UIImage *oImage = [UIImage imageNamed:sImageName];
    UIImageView *oImageView = [[UIImageView alloc] initWithImage:oImage];
    oImageView.contentMode = UIViewContentModeCenter;
    return oImageView;
}

#pragma mark Navigation

- (IBAction)unwindToMealSummary:(UIStoryboardSegue *)segue {
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oMealSummaryViewProfileSegue"]) {
        if([m_oCurrentMealUserModel.m_sUserName isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"]])
        {
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
            NSMutableArray *oViewHierarchy =[[NSMutableArray alloc] initWithArray:[self.navigationController viewControllers]];
            [oViewHierarchy removeObject:self];
            self.navigationController.viewControllers = oViewHierarchy;
            return;
        }
        
        ViewProfile_ViewController *oViewProfile_ViewController = (ViewProfile_ViewController *) [segue destinationViewController];
        oViewProfile_ViewController.m_sSearchedUserName = m_oCurrentMealUserModel.m_sUserName;
        oViewProfile_ViewController.m_sBackSegue = @"oMealSummarySegue";
    }
    else if ([segue.identifier isEqualToString:@"oSuggestedTimesSegue"]) {
        SuggestedTimes_ViewController *oSuggestedTimes_ViewController = (SuggestedTimes_ViewController *) [segue destinationViewController];
        oSuggestedTimes_ViewController.m_sToken = m_sToken;
        oSuggestedTimes_ViewController.m_oMealUserModels = m_oInvitedMealUserModels;
        [oSuggestedTimes_ViewController.m_oMealUserModels addObjectsFromArray:m_oCurrentMealUserModels];
    }
    else if ([segue.identifier isEqualToString:@"oRestaurantVotingSegue"]) {
        RestaurantVoting_ViewController *oRestaurantVoting_ViewController = (RestaurantVoting_ViewController *) [segue destinationViewController];
        oRestaurantVoting_ViewController.m_sToken = m_sToken;
        if(m_bIsHost)
            oRestaurantVoting_ViewController.m_bIsHost = YES;
        else
            oRestaurantVoting_ViewController.m_bIsHost = NO;
    }
}

#pragma mark Click Actions

- (void)clickBack {
    [self performSegueWithIdentifier:@"oMainMenuSegue" sender:nil];
}

- (void)clickVoteRestaurant {
    if(m_oVoteButton.tag == 0)
        [self performSegueWithIdentifier:@"oRestaurantVotingSegue" sender:nil];
}

- (void)clickChooseTime {
    [self performSegueWithIdentifier:@"oSuggestedTimesSegue" sender:nil];
}

- (void)clickYelpLink {
    NSURL *oUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.yelp.com/biz/%@", m_oMealStateModel.m_sRestaurantLocation]];
    if ([[UIApplication sharedApplication] canOpenURL:oUrl]) {
        [[UIApplication sharedApplication] openURL:oUrl];
    }
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ViewMealUsers"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oCurrentMealUserModels removeAllObjects];
            [m_oInvitedMealUserModels removeAllObjects];
            NSArray *oMealUserModels = [MealUserModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            for(MealUserModel *oMealUserModel in oMealUserModels)
            {
                if([oMealUserModel.m_sState isEqualToString:@"INVITED"])
                    [m_oInvitedMealUserModels addObject:oMealUserModel];
                else
                    [m_oCurrentMealUserModels addObject:oMealUserModel];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_oTableView reloadData];
            });
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ViewMealState"])
    {
        NSError *oJsonError;
        m_oMealStateModel = [[MealStateModel alloc] initWithString:oServerResponseModel.m_sOutput error:&oJsonError];
        
        if (!oJsonError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!m_bIsHost) //so both things appear at the same time...
                {
                    [m_oTimeButton setTitle:@"Host is picking a time" forState:UIControlStateNormal];
                    m_oTimeButton.enabled = NO;
                }
                else
                    [m_oTimeButton setTitle:@"Select a date & time" forState:UIControlStateNormal];
                
                if([m_oMealStateModel.m_sTimeSlot length] != 0)
                {
                    [m_oTimeButton setTitle:m_oMealStateModel.m_sTimeSlot forState:UIControlStateNormal];
                    m_oTimeButton.enabled = NO;
                }
                
                if([m_oMealStateModel.m_sRestaurantName length] != 0)
                {
                    [m_oVoteButton setTitle:m_oMealStateModel.m_sRestaurantName forState:UIControlStateNormal];
                    
                    [m_oVoteButton addTarget:self action:@selector(clickYelpLink) forControlEvents:UIControlEventTouchUpInside];
                    m_oVoteButton.tag = 1;
                }
                else
                    [m_oVoteButton setTitle:@"Vote for restaurants" forState:UIControlStateNormal];
            });
            return;
        }
        
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([sAction isEqualToString:@"ChangeMealName"])
    {
        //NSLog(@"%@ - %@ - %@", oServerResponseModel.m_sResult, oServerResponseModel.m_sError, oServerResponseModel.m_sOutput);
        return; //success
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

#pragma mark SectionHeaderViewDelegate

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    NSMutableArray *oIndexPathsToInsert = [[NSMutableArray alloc] init];
    
    if((int) sectionOpened == 0)
    {
        for (NSInteger i = 0; i < m_oCurrentMealUserModels.count; i++) {
            [oIndexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
        }
        m_bIsCurrentSectionOpen = YES;
    }
    else
    {
        for (NSInteger i = 0; i < m_oInvitedMealUserModels.count; i++) {
            [oIndexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
        }
        m_bIsInvitedSectionOpen = YES;
    }
    
    [m_oTableView beginUpdates];
    [m_oTableView insertRowsAtIndexPaths:oIndexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    [m_oTableView endUpdates];
    
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    NSInteger iNumRowsToDelete = [m_oTableView numberOfRowsInSection:sectionClosed];
    
    if((int) sectionClosed == 0)
        m_bIsCurrentSectionOpen = NO;
    else
        m_bIsInvitedSectionOpen = NO;
    
    if (iNumRowsToDelete > 0) {
        for (NSInteger i = 0; i < iNumRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        
        [m_oTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark UITextFieldDelegate Protocol

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *sPostData = [NSString stringWithFormat:@"token=%@&meal_name=%@", m_sToken, textField.text];
    [m_oServerHandler makeRequest:@"/meal_action.php?action=ChangeMealName" postData:sPostData action:@"ChangeMealName"];
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    NSString *sPostData = [NSString stringWithFormat:@"token=%@&meal_name=%@", m_sToken, m_oMealNameField.text];
    [m_oServerHandler makeRequest:@"/meal_action.php?action=ChangeMealName" postData:sPostData action:@"ChangeMealName"];
    
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(m_bIsHost)
        return YES;
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 32;
}
@end

