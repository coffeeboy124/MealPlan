//
//  MainMenu_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/6/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MainMenu_ViewController.h"

@implementation MainMenu_ViewController
@synthesize m_oCurrentMealListModels;
@synthesize m_oInvitedMealListModels;
@synthesize m_oCurrentMealListModel;
@synthesize m_bIsCurrentSectionOpen;
@synthesize m_bIsInvitedSectionOpen;
@synthesize m_oServerHandler;
@synthesize m_oTableView;
@synthesize m_oErrorLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_oCurrentMealListModels = [[NSMutableArray alloc] init];
    m_oInvitedMealListModels = [[NSMutableArray alloc] init];
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    m_oTableView.backgroundColor = [UIColor clearColor];
    m_oServerHandler.m_oDelegate = self;
    m_oErrorLabel.text = @"";
    self.title = @"Home";
    
    UINib *oChatCellNib = [UINib nibWithNibName:@"Chat_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oChatCellNib forCellReuseIdentifier:@"Chat_TableViewCell"];
    UINib *oInviteMealCellNib = [UINib nibWithNibName:@"InviteMeal_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oInviteMealCellNib forCellReuseIdentifier:@"InviteMeal_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void) viewDidAppear:(BOOL)animated{
    m_bIsCurrentSectionOpen = YES;
    m_bIsInvitedSectionOpen = YES;
    
    [m_oServerHandler makeRequest:@"/meal_action.php?action=ListMeals" postData:nil action:@"ListMeals"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ((int) section == 0)
    {
        if(m_bIsCurrentSectionOpen)
            return m_oCurrentMealListModels.count;
        else
            return 0;
    }
    else
    {
        if(m_bIsInvitedSectionOpen)
            return m_oInvitedMealListModels.count;
        else
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if((int) indexPath.section == 0)
    {
        Chat_TableViewCell *oChatCell = [tableView dequeueReusableCellWithIdentifier:@"Chat_TableViewCell"];
        if(!oChatCell)
            oChatCell = [[Chat_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Chat_TableViewCell"];
        
        MealListModel *oMealListModel = m_oCurrentMealListModels[indexPath.row];
        
        NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oMealListModel.m_sUserPic]];
        UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
        [oChatCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
        
        if([oMealListModel.m_sMealName length] == 0)
            oChatCell.m_oUserNameLabel.text = [NSString stringWithFormat:@"%@'s meal", oMealListModel.m_sUserName];
        else
            oChatCell.m_oUserNameLabel.text = oMealListModel.m_sMealName;
        
        if(![oMealListModel.m_sUserState isEqualToString:@"HOST"])
        {
            if(![oMealListModel.m_sMealState isEqualToString:@"VOTING"])
                oChatCell.m_oSublabel.text = oMealListModel.m_sMealState;
            else
                oChatCell.m_oSublabel.text = @"Host is choosing time";
        }
        else
            oChatCell.m_oSublabel.text = [NSString stringWithFormat:@"%@ people have accepted", oMealListModel.m_sAttendance];
        oChatCell.selectionStyle = UITableViewCellSelectionStyleNone;
        oChatCell.m_sToken = oMealListModel.m_sToken;
        oChatCell.m_oChatButton.tag = indexPath.row;
        [oChatCell.m_oChatButton addTarget:self action:@selector(clickChatButton:) forControlEvents:UIControlEventTouchUpInside];
        oChatCell.m_oChatButton.hidden = YES;
        
        UIView *oCrossView = [self viewWithImageName:@"icon_decline.png"];
        UIColor *oGreenColor = [UIColor colorWithRed:1.0 / 255.0 green:152.0 / 255.0 blue:117.0 / 255.0 alpha:1.0];
        UIColor *oYellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];
        [oChatCell setDefaultColor:oYellowColor];
        [oChatCell setSwipeGestureWithView:oCrossView color:oGreenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *oCell, MCSwipeTableViewCellState oState, MCSwipeTableViewCellMode oMode) {
            [self deleteCell:indexPath];
        }];
        
        return oChatCell;
    }
    else
    {
        InviteMeal_TableViewCell *oInviteMealCell = [tableView dequeueReusableCellWithIdentifier:@"InviteMeal_TableViewCell"];
        if(!oInviteMealCell)
            oInviteMealCell = [[InviteMeal_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteMeal_TableViewCell"];
        
        MealListModel *oMealListModel = m_oInvitedMealListModels[indexPath.row];
        
        NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oMealListModel.m_sUserPic]];
        UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
        [oInviteMealCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
        
        if([oMealListModel.m_sMealName length] == 0)
            oInviteMealCell.m_oMealNameLabel.text = [NSString stringWithFormat:@"%@'s meal", oMealListModel.m_sUserName];
        else
            oInviteMealCell.m_oMealNameLabel.text = oMealListModel.m_sMealName;
        
        oInviteMealCell.selectionStyle = UITableViewCellSelectionStyleNone;
        oInviteMealCell.m_sToken = oMealListModel.m_sToken;
        oInviteMealCell.m_oAcceptButton.tag = indexPath.row;
        oInviteMealCell.m_oRejectButton.tag = indexPath.row;
        [oInviteMealCell.m_oAcceptButton addTarget:self action:@selector(clickAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
        [oInviteMealCell.m_oRejectButton addTarget:self action:@selector(clickRejectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        return oInviteMealCell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    
    oSectionHeaderView.m_oDelegate = self;
    oSectionHeaderView.m_iSection = section;
    
    if(section == 0)
    {
        oSectionHeaderView.m_oNameLabel.text = @"Current Meals";
        [oSectionHeaderView.m_oIconImage setImage:[UIImage imageNamed:@"icon_currentmeals.png"]];
    }
    else
    {
        oSectionHeaderView.m_oNameLabel.text = @"Meals Invited To";
        [oSectionHeaderView.m_oIconImage setImage:[UIImage imageNamed:@"icon_mealsinvited.png"]];
    }
    return oSectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *oFooterView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionFooter"];
    
    if(!oFooterView)
        oFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"SectionFooter"];
    
    oFooterView.contentView.backgroundColor = [UIColor clearColor];
    return oFooterView;
}

#pragma mark UITableViewDataDelegate Protocol

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && m_oCurrentMealListModels.count>=indexPath.row)
    {
        m_oCurrentMealListModel = m_oCurrentMealListModels[indexPath.row];
        [self performSegueWithIdentifier:@"oMealSummarySegue" sender:nil];
    }
}

#pragma mark Helper Methods

- (UIView *)viewWithImageName:(NSString *)sImageName {
    UIImage *oImage = [UIImage imageNamed:sImageName];
    UIImageView *oImageView = [[UIImageView alloc] initWithImage:oImage];
    oImageView.contentMode = UIViewContentModeCenter;
    return oImageView;
}

- (void)deleteCell:(NSIndexPath *)oIndexPath {
    if(oIndexPath.section == 0)
     {
         MealListModel *oMealListModel = m_oCurrentMealListModels[oIndexPath.row];
         NSString *sLeaveMealUrl = [NSString stringWithFormat:@"/meal_action.php?action=LeaveMeal&token=%@", oMealListModel.m_sToken];
         [m_oServerHandler makeRequest:sLeaveMealUrl postData:nil action:@"LeaveMeal"];
     }
    
    if((int) oIndexPath.section == 0)
        [m_oCurrentMealListModels removeObjectAtIndex:oIndexPath.row];
    else
        [m_oInvitedMealListModels removeObjectAtIndex:oIndexPath.row];
    
    [UIView animateWithDuration:0.2 animations:^{
        [m_oTableView beginUpdates];
        [m_oTableView deleteRowsAtIndexPaths:@[oIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [m_oTableView endUpdates];
    } completion:nil];
    
    NSIndexSet *oReloadSection = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(oIndexPath.section, 1)];
    [m_oTableView reloadSections:oReloadSection withRowAnimation:UITableViewRowAnimationFade];
    return;
}

#pragma mark Navigation

- (IBAction)unwindToMainMenu:(UIStoryboardSegue *)segue {
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oMealSummarySegue"]) {
        MealSummary_ViewController *oMealSummary_ViewController = (MealSummary_ViewController *) [segue destinationViewController];
        oMealSummary_ViewController.m_sToken = m_oCurrentMealListModel.m_sToken;
        
        if([m_oCurrentMealListModel.m_sUserState isEqualToString:@"HOST"])
            oMealSummary_ViewController.m_bIsHost = YES;
        else
            oMealSummary_ViewController.m_bIsHost = NO;
        
        if([m_oCurrentMealListModel.m_sMealName length] == 0)
            oMealSummary_ViewController.m_sMealName = [NSString stringWithFormat:@"%@'s meal", m_oCurrentMealListModel.m_sUserName];
        else
            oMealSummary_ViewController.m_sMealName = m_oCurrentMealListModel.m_sMealName;
    }
}

#pragma mark Click Actions

- (IBAction)clickCreateMeal:(id)sender {
    [self performSegueWithIdentifier:@"oCreateMealSegue" sender:nil];
}

- (void)clickChatButton:(UIButton *)oSender {
    NSLog(@"Tag: %li", (long)oSender.tag);
}

- (void)clickAcceptButton:(UIButton *)oSender {
    NSIndexPath *oIndexPath = [NSIndexPath indexPathForRow:oSender.tag inSection:1];
    
    m_oErrorLabel.text = @"";
    MealListModel *oMealListModel = m_oInvitedMealListModels[oIndexPath.row];
    NSString *sAcceptInviteUrl = [NSString stringWithFormat:@"/meal_action.php?action=AcceptInvite&token=%@", oMealListModel.m_sToken];
    [m_oServerHandler makeRequest:sAcceptInviteUrl postData:nil action:@"AcceptInvite"];
}

- (void)clickRejectButton:(UIButton *)oSender {
    NSIndexPath *oIndexPath = [NSIndexPath indexPathForRow:oSender.tag inSection:1];
    
    MealListModel *oMealListModel = m_oInvitedMealListModels[oIndexPath.row];
    NSString *sRejectInviteUrl = [NSString stringWithFormat:@"/meal_action.php?action=RejectInvite&token=%@", oMealListModel.m_sToken];
    [m_oServerHandler makeRequest:sRejectInviteUrl postData:nil action:@"RejectInvite"];
    
    [self deleteCell:oIndexPath];
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction{
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ListMeals"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oCurrentMealListModels removeAllObjects];
            [m_oInvitedMealListModels removeAllObjects];
            NSArray *oMealListModels = [MealListModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            for(MealListModel *oMealListModel in oMealListModels)
            {
                if([oMealListModel.m_sUserState isEqualToString:@"INVITED"])
                    [m_oInvitedMealListModels addObject:oMealListModel];
                else
                {
                    if ([oMealListModel.m_sMealState rangeOfString:@"|"].location != NSNotFound) {
                        NSDateFormatter *oDateFormatter = [[NSDateFormatter alloc] init];
                        NSArray *oDate = [oMealListModel.m_sMealState componentsSeparatedByString:@"|"];
                        NSString *sExpirationDate = [NSString stringWithFormat:@"%@%@", oDate[0], oDate[1]];
                        [oDateFormatter setDateFormat:@"LLLL d yyyy"];
                        NSDate *oExpirationDate = [oDateFormatter dateFromString:sExpirationDate];
                        oExpirationDate = [oExpirationDate dateByAddingTimeInterval:60*60*24];

                        if([[NSDate date] timeIntervalSinceDate:oExpirationDate]/86400 >= 1 || oExpirationDate == nil)
                        {
                            NSString *sCompleteMealUrl = [NSString stringWithFormat:@"/meal_action.php?action=CompleteMeal&token=%@", oMealListModel.m_sToken];
                            [m_oServerHandler makeRequest:sCompleteMealUrl postData:nil action:@"CompleteMeal"];
                        }
                    }
                    [m_oCurrentMealListModels addObject:oMealListModel];
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
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"LeaveMeal"])
    {
        return; //success
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"RejectInvite"])
    {
        return; //success
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && ([sAction isEqualToString:@"AcceptInvite"] || [sAction isEqualToString:@"CompleteMeal"]))
    {
        m_bIsCurrentSectionOpen = YES;
        m_bIsInvitedSectionOpen = YES;
        [m_oCurrentMealListModels removeAllObjects];
        [m_oInvitedMealListModels removeAllObjects];
        [m_oServerHandler makeRequest:@"/meal_action.php?action=ListMeals" postData:nil action:@"ListMeals"];
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"FALSE"] && [sAction isEqualToString:@"AcceptInvite"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_oErrorLabel.text = oServerResponseModel.m_sError;
        });
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError{
    return;
}

- (void)processJsonError:(NSError *)oError{
    return;
}

#pragma mark SectionHeaderViewDelegate

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    NSMutableArray *oIndexPathsToInsert = [[NSMutableArray alloc] init];
    
    if((int) sectionOpened == 0)
    {
        for (NSInteger i = 0; i < m_oCurrentMealListModels.count; i++) {
            [oIndexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
        }
        m_bIsCurrentSectionOpen = YES;
    }
    else
    {
        for (NSInteger i = 0; i < m_oInvitedMealListModels.count; i++) {
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
@end
