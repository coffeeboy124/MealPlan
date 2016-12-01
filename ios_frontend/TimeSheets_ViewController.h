//
//  TimeSheets_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/10/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerHandler.h"
#import "TimeSheetModel.h"
#import "TimeSheet_TableViewCell.h"
#import "SectionHeaderView.h"
#import "TimeEditor_ViewController.h"

@interface TimeSheets_ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate>

@property (strong, nonatomic) NSMutableArray *m_oTimeSheetModels;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (assign, nonatomic) int m_iCurrentSheetId;
@property (assign, nonatomic) int m_iCurrentSheetTag;
@property (weak, nonatomic) IBOutlet UIButton *m_oEditSpecificDatesButton;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UILabel *m_oErrorLabel;

- (IBAction)clickNewSchedule:(id)sender;
- (IBAction)clickEditSpecificDates:(id)sender;


@end
