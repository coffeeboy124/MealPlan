//
//  CreateMeal_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/7/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "CreateMeal_ViewController.h"

@implementation CreateMeal_ViewController

@synthesize m_sInvitedUserNames;
@synthesize m_oRelationListModels;
@synthesize m_oServerHandler;
@synthesize m_oTableView;
@synthesize m_oSearchBar;
@synthesize m_oErrorLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"icon_back.png"];
    
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;
    
    UITapGestureRecognizer *oRemoveKeyboardGesture = [[UITapGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(dismissKeyboard)];
    oRemoveKeyboardGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:oRemoveKeyboardGesture];
    
    m_oRelationListModels = [[NSMutableArray alloc] init];
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    m_oSearchBar.delegate = self;
    m_oTableView.backgroundColor = [UIColor clearColor];
    m_oServerHandler.m_oDelegate = self;
    m_sInvitedUserNames = [[NSMutableString alloc] init];
    
    UINib *oSelectCellNib = [UINib nibWithNibName:@"Select_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oSelectCellNib forCellReuseIdentifier:@"Select_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void) viewDidAppear:(BOOL)animated {
    [m_oServerHandler makeRequest:@"/relation_action.php?action=ListRelations" postData:nil action:@"ListRelations"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oCreateMealViewProfileSegue"]) {
        ViewProfile_ViewController *oViewProfile_ViewController = (ViewProfile_ViewController *) [segue destinationViewController];
        oViewProfile_ViewController.m_sSearchedUserName = m_oSearchBar.text;
        oViewProfile_ViewController.m_sBackSegue = @"oCreateMealSegue";
    }
}

- (IBAction)unwindToCreateMeal:(UIStoryboardSegue *)segue {
    return;
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_oRelationListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Select_TableViewCell *oSelectCell = [tableView dequeueReusableCellWithIdentifier:@"Select_TableViewCell"];
    if(!oSelectCell)
        oSelectCell = [[Select_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Select_TableViewCell"];
    
    RelationListModel *oRelationListModel = m_oRelationListModels[indexPath.row];
    
    NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oRelationListModel.m_sUserPic]];
    UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
    [oSelectCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
    
    oSelectCell.m_oUserNameLabel.text = oRelationListModel.m_sUserName;
    oSelectCell.m_oCheckButton.selected = [oRelationListModel.m_oDidCheck boolValue];
    
    oSelectCell.m_oCheckButton.tag = indexPath.row;
    [oSelectCell.m_oCheckButton addTarget:self action:@selector(clickCheckButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return oSelectCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    
    if (!oSectionHeaderView) {
        oSectionHeaderView = [[SectionHeaderView alloc] initWithReuseIdentifier:@"SectionHeader"];
    }
    
    oSectionHeaderView.m_oExpandButton.hidden = YES;
    oSectionHeaderView.m_oIconImage.hidden = YES;
    oSectionHeaderView.m_oNameLabel.text = @"Invite Friends";
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

#pragma mark Click actions

- (void)clickBack {
    [self performSegueWithIdentifier:@"oMainMenuSegue" sender:nil];
}

- (IBAction)clickSendInvite:(UIButton *)sender {
    NSArray *oSelectCells = [m_oTableView visibleCells];
    
    int i=0;
    for (Select_TableViewCell *oSelectCell in oSelectCells)
    {
        if(oSelectCell.m_oCheckButton.selected == YES)
        {
            RelationListModel *oRelationListModel = m_oRelationListModels[i];
            [m_sInvitedUserNames appendFormat:@"%@,", oRelationListModel.m_sUserName];
        }
        i++;
    }
    if((int) [m_sInvitedUserNames length] != 0)
        [m_sInvitedUserNames setString:[m_sInvitedUserNames substringToIndex:[m_sInvitedUserNames length]-1]];
    
    [m_oServerHandler makeRequest:@"/meal_action.php?action=CreateMeal" postData:nil action:@"CreateMeal"];
}

- (void)clickCheckButton:(UIButton *)oButton {
    RelationListModel *oRelationListModel = m_oRelationListModels[(int)oButton.tag];
    if([oRelationListModel.m_oDidCheck boolValue] == NO)
        oRelationListModel.m_oDidCheck = [NSNumber numberWithBool:YES];
    else
        oRelationListModel.m_oDidCheck = [NSNumber numberWithBool:NO];
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

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ListRelations"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oRelationListModels removeAllObjects];
            NSArray *oRelationListModels = [RelationListModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            
            for(RelationListModel *oRelationListModel in oRelationListModels)
            {
                if([oRelationListModel.m_sState isEqualToString:@"ACCEPTED"])
                {
                    oRelationListModel.m_oDidCheck = [NSNumber numberWithBool:NO];
                    [m_oRelationListModels addObject:oRelationListModel];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_oTableView reloadData];
            });
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([sAction isEqualToString:@"CreateMeal"])
    {
        if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"])
        {
            NSString *sPostData = [NSString stringWithFormat:@"token=%@&InvitedUserNames=%@", oServerResponseModel.m_sOutput, m_sInvitedUserNames];
            [m_oServerHandler makeRequest:@"/meal_action.php?action=InviteGuest" postData:sPostData action:@"InviteGuest"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"oMainMenuSegue" sender:nil];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                m_oErrorLabel.text = oServerResponseModel.m_sError;
            });
        }

    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"CreateMeal"])
    {
        NSLog(@"%@", oServerResponseModel.m_sError);
    }
    else if([sAction isEqualToString:@"InviteGuest"])
    {
        
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if([m_oSearchBar.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"]])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
        return;
    }
    [self performSegueWithIdentifier:@"oCreateMealViewProfileSegue" sender:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
    }
}

- (void) dismissKeyboard
{
    [m_oSearchBar resignFirstResponder];
}

@end

