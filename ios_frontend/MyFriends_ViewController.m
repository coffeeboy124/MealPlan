//
//  MyFriends_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/12/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MyFriends_ViewController.h"

@implementation MyFriends_ViewController

@synthesize m_oAcceptedRelationListModels;
@synthesize m_oInvitedRelationListModels;
@synthesize m_oCurrentRelationListModel;
@synthesize m_bIsAcceptedSectionOpen;
@synthesize m_bIsInvitedSectionOpen;
@synthesize m_oServerHandler;
@synthesize m_oTableView;
@synthesize m_oSearchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *oRemoveKeyboardGesture = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    oRemoveKeyboardGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:oRemoveKeyboardGesture];
    
    m_oAcceptedRelationListModels = [[NSMutableArray alloc] init];
    m_oInvitedRelationListModels = [[NSMutableArray alloc] init];
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    m_oTableView.backgroundColor = [UIColor clearColor];
    m_oSearchBar.delegate = self;
    m_oServerHandler.m_oDelegate = self;
    self.title = @"Friends";
    
    UINib *oPersonCellNib = [UINib nibWithNibName:@"Person_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oPersonCellNib forCellReuseIdentifier:@"Person_TableViewCell"];
    UINib *oInviteFriendCellNib = [UINib nibWithNibName:@"InviteFriend_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oInviteFriendCellNib forCellReuseIdentifier:@"InviteFriend_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void) viewDidAppear:(BOOL)animated {
    m_bIsAcceptedSectionOpen = YES;
    m_bIsInvitedSectionOpen = YES;
    
    [m_oServerHandler makeRequest:@"/relation_action.php?action=ListRelations" postData:nil action:@"ListRelations"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oViewProfileSegue"]) {
        ViewProfile_ViewController *oViewProfile_ViewController = (ViewProfile_ViewController *) [segue destinationViewController];
        oViewProfile_ViewController.m_sSearchedUserName = m_oCurrentRelationListModel.m_sUserName;
        if (m_oSearchBar.text && m_oSearchBar.text.length > 0)
        {
            oViewProfile_ViewController.m_sSearchedUserName = m_oSearchBar.text;
        }
        oViewProfile_ViewController.m_sBackSegue = @"oMyFriendsSegue";
    }
}

- (IBAction)unwindToMyFriends:(UIStoryboardSegue *)segue {
    return;
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((int) section == 0)
    {
        if(m_bIsAcceptedSectionOpen)
            return m_oAcceptedRelationListModels.count;
        return 0;
    }
    else
    {
        if(m_bIsInvitedSectionOpen)
            return m_oInvitedRelationListModels.count;
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((int) indexPath.section == 0)
    {
        Person_TableViewCell *oPersonCell = [tableView dequeueReusableCellWithIdentifier:@"Person_TableViewCell"];
        if(!oPersonCell)
            oPersonCell = [[Person_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Person_TableViewCell"];
        
        RelationListModel *oRelationListModel = m_oAcceptedRelationListModels[indexPath.row];
        
        NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oRelationListModel.m_sUserPic]];
        UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
        [oPersonCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
        
        oPersonCell.m_oUserNameLabel.text = oRelationListModel.m_sUserName;
        oPersonCell.m_oButton.hidden = YES;
        oPersonCell.m_oSubLabel.text = @"";
        oPersonCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *oCrossView = [self viewWithImageName:@"icon_decline.png"];
        UIColor *oGreenColor = [UIColor colorWithRed:1.0 / 255.0 green:152.0 / 255.0 blue:117.0 / 255.0 alpha:1.0];
        UIColor *oYellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];
        [oPersonCell setDefaultColor:oYellowColor];
        [oPersonCell setSwipeGestureWithView:oCrossView color:oGreenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *oCell, MCSwipeTableViewCellState oState, MCSwipeTableViewCellMode oMode) {
            [self deleteCell:indexPath deleteFromServer:YES];
        }];
        
        return oPersonCell;
    }
    else
    {
        InviteFriend_TableViewCell *oInviteFriendCell = [tableView dequeueReusableCellWithIdentifier:@"InviteFriend_TableViewCell"];
        if(!oInviteFriendCell)
            oInviteFriendCell = [[InviteFriend_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteFriend_TableViewCell"];
        
        RelationListModel *oRelationListModel = m_oInvitedRelationListModels[indexPath.row];
        
        NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oRelationListModel.m_sUserPic]];
        UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
        [oInviteFriendCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
        
        oInviteFriendCell.m_oUserNameLabel.text = oRelationListModel.m_sUserName;
        oInviteFriendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        oInviteFriendCell.m_oAcceptButton.tag = indexPath.row;
        oInviteFriendCell.m_oRejectButton.tag = indexPath.row;
        [oInviteFriendCell.m_oAcceptButton addTarget:self action:@selector(clickAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
        [oInviteFriendCell.m_oRejectButton addTarget:self action:@selector(clickRejectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return oInviteFriendCell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    oSectionHeaderView.m_oDelegate = self;
    oSectionHeaderView.m_iSection = section;
    
    if(section == 0)
        oSectionHeaderView.m_oNameLabel.text = @"Meal Friends";
    else
        oSectionHeaderView.m_oNameLabel.text = @"Friend Requests";
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
        m_oCurrentRelationListModel = m_oAcceptedRelationListModels[indexPath.row];
    else
        m_oCurrentRelationListModel = m_oInvitedRelationListModels[indexPath.row];
    [self performSegueWithIdentifier:@"oViewProfileSegue" sender:nil];
}

#pragma mark Helper Methods

- (UIView *)viewWithImageName:(NSString *)sImageName {
    UIImage *oImage = [UIImage imageNamed:sImageName];
    UIImageView *oImageView = [[UIImageView alloc] initWithImage:oImage];
    oImageView.contentMode = UIViewContentModeCenter;
    return oImageView;
}

- (void)deleteCell:(NSIndexPath *)oIndexPath deleteFromServer:(BOOL)bDeleteFromServer {
    if(bDeleteFromServer)
    {
        RelationListModel *oRelationListModel;
        if(oIndexPath.section == 0)
            oRelationListModel = m_oAcceptedRelationListModels[oIndexPath.row];
        else
            oRelationListModel = m_oInvitedRelationListModels[oIndexPath.row];
        NSString *sLeaveMealUrl = [NSString stringWithFormat:@"/relation_action.php?action=DeleteRelation&user_name=%@", oRelationListModel.m_sUserName];
        [m_oServerHandler makeRequest:sLeaveMealUrl postData:nil action:@"DeleteRelation"];
    }
    
    if((int) oIndexPath.section == 0)
        [m_oAcceptedRelationListModels removeObjectAtIndex:oIndexPath.row];
    else
        [m_oInvitedRelationListModels removeObjectAtIndex:oIndexPath.row];
    
    [UIView animateWithDuration:0.2 animations:^{
        [m_oTableView beginUpdates];
        [m_oTableView deleteRowsAtIndexPaths:@[oIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [m_oTableView endUpdates];
    } completion:nil];
    
    NSIndexSet *oReloadSection = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(oIndexPath.section, 1)];
    [m_oTableView reloadSections:oReloadSection withRowAnimation:UITableViewRowAnimationFade];
    return;
}

#pragma mark Click Actions

- (void)clickAcceptButton:(UIButton *)oSender {
    NSIndexPath *oIndexPath = [NSIndexPath indexPathForRow:oSender.tag inSection:1];
    
    RelationListModel *oRelationListModel = m_oInvitedRelationListModels[oIndexPath.row];
    NSString *sLeaveMealUrl = [NSString stringWithFormat:@"/relation_action.php?action=AcceptRelation&user_name=%@", oRelationListModel.m_sUserName];
    [m_oServerHandler makeRequest:sLeaveMealUrl postData:nil action:@"AcceptRelation"];
    
    [self deleteCell:oIndexPath deleteFromServer:NO];
}

- (void)clickRejectButton:(UIButton *)oSender {
    NSIndexPath *oIndexPath = [NSIndexPath indexPathForRow:oSender.tag inSection:1];
    
    RelationListModel *oRelationListModel = m_oInvitedRelationListModels[oIndexPath.row];
    NSString *sLeaveMealUrl = [NSString stringWithFormat:@"/relation_action.php?action=DeleteRelation&user_name=%@", oRelationListModel.m_sUserName];
    [m_oServerHandler makeRequest:sLeaveMealUrl postData:nil action:@"DeleteRelation"];
    
    [self deleteCell:oIndexPath deleteFromServer:NO];
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ListRelations"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oAcceptedRelationListModels removeAllObjects];
            [m_oInvitedRelationListModels removeAllObjects];
            NSArray *oRelationListModels = [RelationListModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            for(RelationListModel *oRelationListModel in oRelationListModels)
            {
                if([oRelationListModel.m_sState isEqualToString:@"INVITED"])
                    [m_oInvitedRelationListModels addObject:oRelationListModel];
                else
                    [m_oAcceptedRelationListModels addObject:oRelationListModel];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_oTableView reloadData];
            });
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"AcceptRelation"])
    {
        m_bIsAcceptedSectionOpen = YES;
        m_bIsInvitedSectionOpen = YES;
        [m_oAcceptedRelationListModels removeAllObjects];
        [m_oInvitedRelationListModels removeAllObjects];
        [m_oServerHandler makeRequest:@"/relation_action.php?action=ListRelations" postData:nil action:@"ListRelations"];
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
        for (NSInteger i = 0; i < m_oAcceptedRelationListModels.count; i++) {
            [oIndexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
        }
        m_bIsAcceptedSectionOpen = YES;
    }
    else
    {
        for (NSInteger i = 0; i < m_oInvitedRelationListModels.count; i++) {
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
        m_bIsAcceptedSectionOpen = NO;
    else
        m_bIsInvitedSectionOpen = NO;
    
    if (iNumRowsToDelete > 0) {
        for (NSInteger i = 0; i < iNumRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        
        [m_oTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UISearchBarDelegate Methods

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if([m_oSearchBar.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"]])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
        return;
    }
    [self performSegueWithIdentifier:@"oViewProfileSegue" sender:nil];
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
