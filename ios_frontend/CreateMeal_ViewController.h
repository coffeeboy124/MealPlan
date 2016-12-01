//
//  CreateMeal_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/7/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "RelationListModel.h"
#import "Select_TableViewCell.h"
#import "SectionHeaderView.h"
#import "ViewProfile_ViewController.h"

@interface CreateMeal_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ServerHandlerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableString *m_sInvitedUserNames;
@property (strong, nonatomic) NSMutableArray *m_oRelationListModels;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *m_oSearchBar;
@property (weak, nonatomic) IBOutlet UILabel *m_oErrorLabel;

- (IBAction)clickSendInvite:(UIButton *)sender;

@end
