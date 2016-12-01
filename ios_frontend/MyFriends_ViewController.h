//
//  MyFriends_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/12/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "Person_TableViewCell.h"
#import "InviteFriend_TableViewCell.h"
#import "RelationListModel.h"
#import "SectionHeaderView.h"
#import "ViewProfile_ViewController.h"

@interface MyFriends_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate, SectionHeaderViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *m_oAcceptedRelationListModels;
@property (strong, nonatomic) NSMutableArray *m_oInvitedRelationListModels;
@property (strong, nonatomic) RelationListModel *m_oCurrentRelationListModel;
@property (assign, nonatomic) BOOL m_bIsAcceptedSectionOpen;
@property (assign, nonatomic) BOOL m_bIsInvitedSectionOpen;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *m_oSearchBar;

@end
