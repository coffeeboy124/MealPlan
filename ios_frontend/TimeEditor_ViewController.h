//
//  TimeEditor_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeScroller.h"
#import "TimeSlot.h"
#import "ActionSheetDatePicker.h"
#import "ServerHandler.h"
#import "TimeListModel.h"
#import "TimeHandler.h"

@interface TimeEditor_ViewController : UIViewController <TimeScrollerDelegate, TimeSlotDelegate, ServerHandlerDelegate>


@property (assign, nonatomic) CGFloat m_fHourHeight;
@property (assign, nonatomic) CGFloat m_fMinuteHeight;
@property (assign, nonatomic) int m_iPage;
@property (assign, nonatomic) int m_iSheetId;
@property (strong, nonatomic) NSArray *m_oTimeSlots;
@property (strong, nonatomic) TimeSlot *m_oCurrentTimeSlot;
@property (strong, nonatomic) UIView *m_oTimeEditorPopupView;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (assign, nonatomic) BOOL m_bTimeEditorOpen;
@property (assign, nonatomic) BOOL m_bIsNewSlot;
@property (assign, nonatomic) float m_fOldStartTime;
@property (assign, nonatomic) float m_fOldEndTime;

@property (weak, nonatomic) IBOutlet TimeScroller *m_oTimeScroller;
@property (weak, nonatomic) IBOutlet UIScrollView *m_oScrollView;
@property (weak, nonatomic) IBOutlet UIButton *m_oStartTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oEndTimeButton;
@property (weak, nonatomic) IBOutlet UILabel *m_oErrorLabel;

- (IBAction)clickCancel:(id)sender;
- (IBAction)clickSave:(id)sender;
- (IBAction)clickDelete:(id)sender;

@end
