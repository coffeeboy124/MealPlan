//
//  RestaurantVoting_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "Vote_TableViewCell.h"
#import "VoteListModel.h"
#import "RestaurantSelection_ViewController.h"
#import "YelpListModel.h"
#import "SectionHeaderView.h"

@interface RestaurantVoting_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate>

@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (strong, nonatomic) NSMutableArray *m_oVoteListModels;
@property (strong, nonatomic) NSMutableArray *m_oSelectedCells;
@property (strong, nonatomic) NSString *m_sToken;
@property (assign, nonatomic) BOOL m_bIsHost;

@property (weak, nonatomic) IBOutlet UIView *m_oYelpView;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UIImageView *m_oProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *m_oRatingImage;
@property (weak, nonatomic) IBOutlet UILabel *m_oNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oReviewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oMilesFromLocLabel;

- (IBAction)clickSuggestRestaurant:(id)sender;

@end
