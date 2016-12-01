//
//  SuggestedTimes_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/13/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "MealTimeModel.h"
#import "MealUserModel.h"
#import "Time_CollectionViewCell.h"
#import "Person_TableViewCell.h"
#import "SectionHeaderView.h"
#import "ViewProfile_ViewController.h"
#import "ActionSheetDatePicker.h"
#import "TimeHandler.h"

@interface SuggestedTimes_ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate>

@property (assign, nonatomic) BOOL m_bIsHost;
@property (assign, nonatomic) int m_iCollectionViewIndex;
@property (strong, nonatomic) NSMutableArray *m_oMealUserModels;
@property (strong, nonatomic) NSMutableArray *m_oExcludedMealUserModels;
@property (strong, nonatomic) MealUserModel *m_oCurrentMealUserModel;
@property (strong, nonatomic) NSString *m_sToken;
@property (strong, nonatomic) NSMutableArray *m_oMealTimeModels;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (weak, nonatomic) IBOutlet UICollectionView *m_oCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UILabel *m_oDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_oStartTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oEndTimeButton;
@property (weak, nonatomic) IBOutlet UILabel *m_oStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oEndTimeLabel;


@property (weak, nonatomic) IBOutlet UILabel *m_oAttendingLabel;

- (IBAction)clickConfirm:(id)sender;

@end
