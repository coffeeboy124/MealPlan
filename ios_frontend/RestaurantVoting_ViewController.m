//
//  RestaurantVoting_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "RestaurantVoting_ViewController.h"

@implementation RestaurantVoting_ViewController

@synthesize m_oServerHandler;
@synthesize m_oVoteListModels;
@synthesize m_oSelectedCells;
@synthesize m_sToken;
@synthesize m_bIsHost;
@synthesize m_oTableView;
@synthesize m_oYelpView;
@synthesize m_oProfileImage;
@synthesize m_oRatingImage;
@synthesize m_oNameLabel;
@synthesize m_oAddressLabel;
@synthesize m_oReviewsLabel;
@synthesize m_oMilesFromLocLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"icon_back.png"];
    
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;

    UIBarButtonItem *oFinishButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Finish"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clickFinish)];
    if(m_bIsHost)
        self.navigationItem.rightBarButtonItem = oFinishButton;
    
    m_oVoteListModels = [[NSMutableArray alloc] init];
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    m_oTableView.backgroundColor = [UIColor clearColor];
    m_oSelectedCells = [[NSMutableArray alloc] init];
    UITapGestureRecognizer *oTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(clickYelpView)];
    [m_oYelpView addGestureRecognizer:oTapGesture];
    
    UINib *oVoteCellNib = [UINib nibWithNibName:@"Vote_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oVoteCellNib forCellReuseIdentifier:@"Vote_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void) viewDidAppear:(BOOL)animated{
    NSString *sListVotesUrl = [NSString stringWithFormat:@"/restaurant_action.php?action=ListVotes&token=%@", m_sToken];
    [m_oServerHandler makeRequest:sListVotesUrl postData:nil action:@"ListVotes"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (IBAction)unwindToRestaurantVoting:(UIStoryboardSegue *)segue {
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oRestaurantSelectionSegue"]) {
        RestaurantSelection_ViewController *oRestaurantSelection_ViewController = (RestaurantSelection_ViewController *) [segue destinationViewController];
        oRestaurantSelection_ViewController.m_sToken = m_sToken;
    }
}

#pragma mark Click Action

- (IBAction)clickSuggestRestaurant:(id)sender {
    [self performSegueWithIdentifier:@"oRestaurantSelectionSegue" sender:nil];
}

- (void)clickBack {
    [self performSegueWithIdentifier:@"oMealSummarySegue" sender:nil];
}

- (void)clickVoteButton:(UIButton *)oButton {
    NSString *sPostData;
    
    VoteListModel *oVoteListModel = m_oVoteListModels[oButton.tag];
    if([oVoteListModel.m_oDidVote boolValue]) //unvote your vote!
    {
        NSString *sVoteId = [oVoteListModel.m_oVoteIds objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"]];
        
        NSString *sDeleteVoteUrl = [NSString stringWithFormat:@"/restaurant_action.php?action=DeleteVote&mr_id=%@", sVoteId];
        [m_oServerHandler makeRequest:sDeleteVoteUrl postData:sPostData action:@"DeleteVote"];
        
        if(m_oVoteListModels.count == 0)
        {
            m_oProfileImage.image = nil;
            m_oRatingImage.image = nil;
            m_oNameLabel.text = @"";
            m_oAddressLabel.text = @"";
            m_oReviewsLabel.text = @"";
            m_oMilesFromLocLabel.text = @"";
        }
    }
    else
    {
        sPostData = [NSString stringWithFormat:@"token=%@&restaurant_id=%@&state=%@&restaurant_name=%@", m_sToken, oVoteListModel.m_sRestaurantId, @"LIKED", oVoteListModel.m_sRestaurantName];
        [m_oServerHandler makeRequest:@"/restaurant_action.php?action=CreateVote" postData:sPostData action:@"CreateVote"];
    }
}

- (void)clickYelpButton:(UIButton *)oButton {
    VoteListModel *oVoteListModel = m_oVoteListModels[oButton.tag];
    
    NSURL *oUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.yelp.com/biz/%@", oVoteListModel.m_sRestaurantId]];
    if ([[UIApplication sharedApplication] canOpenURL:oUrl]) {
        [[UIApplication sharedApplication] openURL:oUrl];
    }
    NSLog(@"%@", oVoteListModel.m_sRestaurantId);
    
}

- (void)clickYelpView {
    if(m_oVoteListModels.count > 0)
    {
        VoteListModel *oVoteListModel = m_oVoteListModels[0];
        
        NSURL *oUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://www.yelp.com/biz/%@", oVoteListModel.m_sRestaurantId]];
        if ([[UIApplication sharedApplication] canOpenURL:oUrl]) {
            [[UIApplication sharedApplication] openURL:oUrl];
        }
    }
}

- (void)clickFinish {
    VoteListModel *oVoteListModel = [m_oVoteListModels firstObject];
    NSString *sPostData = [NSString stringWithFormat:@"token=%@&restaurant_name=%@&restaurant_location=%@", m_sToken, oVoteListModel.m_sRestaurantName, oVoteListModel.m_sRestaurantId];
    
    [m_oServerHandler makeRequest:@"/meal_action.php?action=SelectRestaurant" postData:sPostData action:@"SelectRestaurant"];
    [self performSegueWithIdentifier:@"oMealSummarySegue" sender:nil];
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_oVoteListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Vote_TableViewCell *oVoteCell = [tableView dequeueReusableCellWithIdentifier:@"Vote_TableViewCell"];
    if(!oVoteCell)
        oVoteCell = [[Vote_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Vote_TableViewCell"];
    
    VoteListModel *oVoteListModel = m_oVoteListModels[indexPath.row];
    
    oVoteCell.m_oNameLabel.text = oVoteListModel.m_sRestaurantName;
    oVoteCell.m_oVotesLabel.text = [NSString stringWithFormat:@"%d", [oVoteListModel.m_oVoteCount intValue]];

    if(![oVoteListModel.m_sState isEqualToString:@"LIKED"])
        oVoteCell.m_oSuggestedByLabel.text = oVoteListModel.m_sState;
    else
        oVoteCell.m_oSuggestedByLabel.text = @"";
    oVoteCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if([oVoteListModel.m_oDidVote boolValue])
        [oVoteCell.m_oVoteButton setBackgroundImage:[UIImage imageNamed:@"button_voteforrestaurant.png"] forState:UIControlStateNormal];
    else
        [oVoteCell.m_oVoteButton setBackgroundImage:[UIImage imageNamed:@"button_voteforrestaurant2.png"] forState:UIControlStateNormal];
    
    oVoteCell.m_oVoteButton.tag = indexPath.row;
    [oVoteCell.m_oVoteButton addTarget:self action:@selector(clickVoteButton:) forControlEvents:UIControlEventTouchUpInside];
    oVoteCell.m_oYelpButton.tag = indexPath.row;
    [oVoteCell.m_oYelpButton addTarget:self action:@selector(clickYelpButton:) forControlEvents:UIControlEventTouchUpInside];
    return oVoteCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    
    if (!oSectionHeaderView) {
        oSectionHeaderView = [[SectionHeaderView alloc] initWithReuseIdentifier:@"SectionHeader"];
    }
    
    oSectionHeaderView.m_oExpandButton.hidden = YES;
    oSectionHeaderView.m_oNameLabel.text = @"Candidate Restaurants";
    oSectionHeaderView.m_oIconImage.hidden = YES;
    return oSectionHeaderView;
}

#pragma mark UITableViewDataDelegate Protocol

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *oNumber = m_oSelectedCells[indexPath.row];
    if([oNumber intValue] == 1)
        return 100;
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *oNumber = m_oSelectedCells[indexPath.row];
    if([oNumber intValue] == 0)
    {
        m_oSelectedCells[indexPath.row] = [NSNumber numberWithInt:1];
    }
    else
    {
        m_oSelectedCells[indexPath.row] = [NSNumber numberWithInt:0];
    }
    
    [tableView beginUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView endUpdates];
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ListVotes"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oVoteListModels removeAllObjects];
            NSMutableArray *oVoteListModels = [VoteListModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            VoteListModel *oVoteListModel = [oVoteListModels firstObject];
            [m_oServerHandler queryBusinessInfoForBusinessId:oVoteListModel.m_sRestaurantId action:@"RestaurantLookUp"];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            
            VoteListModel *oTempVoteListModel;
            NSString *sCurrentRestaurantId;
            for(int i = 0; i < oVoteListModels.count; i++)
            {
                oVoteListModel = oVoteListModels[i];
                sCurrentRestaurantId = oVoteListModel.m_sRestaurantId;
                
                if([oVoteListModel.m_sUserName isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"]])
                    oVoteListModel.m_oDidVote = [NSNumber numberWithBool:YES];
                else
                    oVoteListModel.m_oDidVote = [NSNumber numberWithBool:NO];
                oVoteListModel.m_oVoteCount = [NSNumber numberWithInt:1];
                
                oVoteListModel.m_oVoteIds = [[NSMutableDictionary alloc] init];
                [oVoteListModel.m_oVoteIds setObject:oVoteListModel.m_sId forKey:oVoteListModel.m_sUserName];
                
                if([oVoteListModel.m_sState isEqualToString:@"PROPOSED"])
                    oVoteListModel.m_sState = [NSString stringWithFormat:@"Suggested by %@", oVoteListModel.m_sUserName];
                
                for(int j = i; j < oVoteListModels.count; j++)
                {
                    if(j == i)
                        continue;
                    
                    oTempVoteListModel = oVoteListModels[j];
                    
                    if([oTempVoteListModel.m_sRestaurantId isEqualToString:sCurrentRestaurantId])
                    {
                        if([oTempVoteListModel.m_sState isEqualToString:@"PROPOSED"])
                            oVoteListModel.m_sState = [NSString stringWithFormat:@"Suggested by %@", oTempVoteListModel.m_sUserName];
                        
                        if([oTempVoteListModel.m_sUserName isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"]])
                            oVoteListModel.m_oDidVote = [NSNumber numberWithBool:YES];
                        
                        int iVoteCount = [oVoteListModel.m_oVoteCount intValue];
                        oVoteListModel.m_oVoteCount = [NSNumber numberWithInt:iVoteCount + 1];
                        
                        [oVoteListModel.m_oVoteIds setObject:oTempVoteListModel.m_sId forKey:oTempVoteListModel.m_sUserName];
                        [oVoteListModels removeObject:oTempVoteListModel];
                        j--;
                    }
                }

                [m_oVoteListModels addObject:oVoteListModel];
            }
            
            m_oVoteListModels = [NSMutableArray arrayWithArray:[m_oVoteListModels sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = [(VoteListModel*)a m_oVoteCount];
                NSNumber *second = [(VoteListModel*)b m_oVoteCount];
                return [second compare:first];
            }]];
            
            for(int i = 0; i < m_oVoteListModels.count; i++)
            {
                [m_oSelectedCells addObject:[NSNumber numberWithInt:0]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_oTableView reloadData];
            });
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && ([sAction isEqualToString:@"CreateVote"] || [sAction isEqualToString:@"DeleteVote"]))
    {
        [m_oVoteListModels removeAllObjects];
        NSString *sListVotesUrl = [NSString stringWithFormat:@"/restaurant_action.php?action=ListVotes&token=%@", m_sToken];
        [m_oServerHandler makeRequest:sListVotesUrl postData:nil action:@"ListVotes"];
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"SelectRestaurant"])
    {
        NSLog(@"YES");
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

- (void)processYelpResponseModel:(NSData *)oResponseData action:(NSString *)sAction {
    NSError *oJsonError;
    YelpListModel *oYelpListModel = [[YelpListModel alloc] initWithData:oResponseData error:&oJsonError];
    
    if (oJsonError) {
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    
    if([sAction isEqualToString:@"RestaurantLookUp"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *oProfilePicUrl = [NSURL URLWithString:oYelpListModel.m_sProfileUrl];
             [m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:nil];
            NSURL *oRatingPicUrl = [NSURL URLWithString:oYelpListModel.m_sRatingUrl];
             [m_oRatingImage sd_setImageWithURL:oRatingPicUrl placeholderImage:nil];
             
            m_oNameLabel.text = oYelpListModel.m_sName;
            if (oYelpListModel.m_oAddress != nil && oYelpListModel.m_oAddress.m_oAddress.count > 0)
                m_oAddressLabel.text = oYelpListModel.m_oAddress.m_oAddress[0];
            else
                m_oAddressLabel.text = @"Address Unavailable";
            m_oReviewsLabel.text = [NSString stringWithFormat:@"%d reviews on yelp", oYelpListModel.m_iReviewCount];
        });
    }
    
    return;
}

@end
