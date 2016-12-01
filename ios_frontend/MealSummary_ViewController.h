//
//  MealSummary_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/12/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "Person_TableViewCell.h"
#import "MealUserModel.h"
#import "MealStateModel.h"
#import "SectionHeaderView.h"
#import "ViewProfile_ViewController.h"
#import "SuggestedTimes_ViewController.h"
#import "RestaurantVoting_ViewController.h"

@interface MealSummary_ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate, SectionHeaderViewDelegate>

@property (strong, nonatomic) NSMutableArray *m_oCurrentMealUserModels;
@property (strong, nonatomic) NSMutableArray *m_oInvitedMealUserModels;
@property (strong, nonatomic) MealUserModel *m_oCurrentMealUserModel;
@property (assign, nonatomic) BOOL m_bIsCurrentSectionOpen;
@property (assign, nonatomic) BOOL m_bIsInvitedSectionOpen;
@property (assign, nonatomic) BOOL m_bIsHost;
@property (strong, nonatomic) NSString *m_sToken;
@property (strong, nonatomic) NSString *m_sMealState;
@property (strong, nonatomic) NSString *m_sMealName;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (strong, nonatomic) MealStateModel *m_oMealStateModel;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UIButton *m_oTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oVoteButton;
@property (weak, nonatomic) IBOutlet UITextField *m_oMealNameField;

@end
