//
//  MainMenu_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/6/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "Chat_TableViewCell.h"
#import "InviteMeal_TableViewCell.h"
#import "MealListModel.h"
#import "SectionHeaderView.h"
#import "MealSummary_ViewController.h"

@interface MainMenu_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate, SectionHeaderViewDelegate>

@property (strong, nonatomic) NSMutableArray *m_oCurrentMealListModels;
@property (strong, nonatomic) NSMutableArray *m_oInvitedMealListModels;
@property (strong, nonatomic) MealListModel *m_oCurrentMealListModel;
@property (assign, nonatomic) BOOL m_bIsCurrentSectionOpen;
@property (assign, nonatomic) BOOL m_bIsInvitedSectionOpen;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UILabel *m_oErrorLabel;

- (IBAction)clickCreateMeal:(id)sender;

@end
