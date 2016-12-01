//
//  TimeEditor_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "TimeEditor_ViewController.h"

#define SMALLEST_TIME_SLOTSIZE 30
#define DEFAULT_TIME_SLOTSIZE 60
#define TIME_PAGE_HEIGHT 1250
#define TIME_PAGE_PADDING 17.5
#define START_TIME_BUTTON_TAG 0
#define END_TIME_BUTTON_TAG 1
#define UP_SCROLL_THRESHOLD .02
#define DOWN_SCROLL_THRESHOLD .55

@implementation TimeEditor_ViewController

@synthesize m_oTimeScroller;
@synthesize m_oScrollView;
@synthesize m_fHourHeight;
@synthesize m_fMinuteHeight;
@synthesize m_iPage;
@synthesize m_iSheetId;
@synthesize m_oTimeSlots;
@synthesize m_oCurrentTimeSlot;
@synthesize m_oTimeEditorPopupView;
@synthesize m_oServerHandler;
@synthesize m_oStartTimeButton;
@synthesize m_oEndTimeButton;
@synthesize m_oErrorLabel;
@synthesize m_bTimeEditorOpen;
@synthesize m_bIsNewSlot;
@synthesize m_fOldStartTime;
@synthesize m_fOldEndTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize size = self.view.bounds.size;
    
    UIView *oTimePageView = [[[NSBundle mainBundle] loadNibNamed:@"TimePage" owner:self options:nil] firstObject];
    oTimePageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, oTimePageView.bounds.size.height);
    m_oScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, oTimePageView.frame.size.height);
    [m_oScrollView addSubview:oTimePageView];
    
    UITapGestureRecognizer *oSingleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [m_oScrollView addGestureRecognizer:oSingleTapGesture];
    
    UIImage *image = [UIImage imageNamed:@"icon_back.png"];
    
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;
    
    self.title = @"Edit Times";
    m_oTimeScroller.m_oDelegate = self;
    m_fHourHeight = (TIME_PAGE_HEIGHT - 2 * TIME_PAGE_PADDING) / 24;
    m_fMinuteHeight = m_fHourHeight / 60;
    m_oTimeEditorPopupView = [[[NSBundle mainBundle] loadNibNamed:@"TimeEditorPopup" owner:self options:nil] firstObject];
    m_oTimeEditorPopupView.frame = CGRectMake(0, size.height - m_oTimeEditorPopupView.bounds.size.height, size.width, m_oTimeEditorPopupView.bounds.size.height);
    m_oStartTimeButton.tag = START_TIME_BUTTON_TAG;
    m_oEndTimeButton.tag = END_TIME_BUTTON_TAG;
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_bTimeEditorOpen = false;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [m_oStartTimeButton addTarget:self action:@selector(clickTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    [m_oEndTimeButton addTarget:self action:@selector(clickTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    id oTemp[7];
    for (int i = 0; i < 7; i++)
        oTemp[i] = [[NSMutableArray alloc] init];
    m_oTimeSlots= [NSArray arrayWithObjects:oTemp count:7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Click actions
- (void)clickBack {
    [self.tabBarController.tabBar setHidden:NO];
    [self performSegueWithIdentifier:@"oTimeSheetSegue" sender:nil];
}

- (IBAction)clickCancel:(id)sender {
    m_bTimeEditorOpen = false;
    m_oTimeScroller.m_bDisabled = NO;
    [m_oCurrentTimeSlot hideButtons];
    [m_oTimeEditorPopupView removeFromSuperview];
    
    if(m_bIsNewSlot)
    {
        for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
        {
            if(oSavedSlot.tag == m_oCurrentTimeSlot.tag)
            {
                [m_oTimeSlots[m_iPage] removeObject:oSavedSlot];
                [oSavedSlot removeFromSuperview];
                return;
            }
        }
    }
    
    if(m_fOldEndTime >= 0 && m_fOldStartTime >=0)
    {
        m_oCurrentTimeSlot.m_iStartMinute = m_fOldStartTime;
        m_oCurrentTimeSlot.m_iEndMinute = m_fOldEndTime;
        [m_oCurrentTimeSlot changeTimeSlot:CGRectMake(0, [self convertToPoints:m_oCurrentTimeSlot.m_iStartMinute] + TIME_PAGE_PADDING, m_oScrollView.bounds.size.width, [self convertToPoints:(m_oCurrentTimeSlot.m_iEndMinute - m_oCurrentTimeSlot.m_iStartMinute)])];
        
        NSString *sPostData = [NSString stringWithFormat:@"start_time=%@&end_time=%@&day=%@&sheet_id=%d", [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iStartMinute isDisplay:NO], [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iEndMinute isDisplay:NO], [TimeHandler convertNumberToDay:m_iPage], m_iSheetId];
        [m_oServerHandler makeRequest:@"time_action.php?action=CreateTime" postData:sPostData action:@"CreateTime"];
    }
}

- (IBAction)clickSave:(id)sender {
    m_bTimeEditorOpen = false;
    m_oTimeScroller.m_bDisabled = NO;
    [m_oTimeEditorPopupView removeFromSuperview];
    [m_oCurrentTimeSlot hideButtons];
    
    if(m_fOldEndTime >= 0 && m_fOldStartTime >=0)
    {
        NSString *sPostData = [NSString stringWithFormat:@"time_slot=%@ %@ %@&sheet_id=%d", [self convertFromMinutesToString:m_fOldStartTime isDisplay:NO], [self convertFromMinutesToString:m_fOldEndTime isDisplay:NO], [TimeHandler convertNumberToDay:m_iPage], m_iSheetId];
        [m_oServerHandler makeRequest:@"time_action.php?action=DeleteTime" postData:sPostData action:@"EditTime"];
    }
    else
    {
        NSString *sPostData = [NSString stringWithFormat:@"start_time=%@&end_time=%@&day=%@&sheet_id=%d", [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iStartMinute isDisplay:NO], [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iEndMinute isDisplay:NO], [TimeHandler convertNumberToDay:m_iPage], m_iSheetId];
        [m_oServerHandler makeRequest:@"time_action.php?action=CreateTime" postData:sPostData action:@"CreateTime"];
    }
}

- (void)clickTimeButton:(id)sender {
    UIButton *oButton = (UIButton *)sender;
    NSArray *oTimes = [oButton.currentTitle componentsSeparatedByString:@":"];
    NSArray *oTimes2 = [oTimes[1] componentsSeparatedByString:@" "];
    int iHours = [oTimes[0] intValue];
    int iMinutes = [oTimes2[0] intValue];
    if([oTimes2[1] isEqualToString:@"PM"])
        iHours = iHours + 12;
    if([oTimes2[1] isEqualToString:@"AM"] && iHours == 12)
        iHours = 0;
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:[self createDateFromMinutes:iMinutes andHours:iHours] target:self action:@selector(timeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = 1;
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(UIButton *)oButton {
    NSString *sPostData = [NSString stringWithFormat:@"time_slot=%@ %@ %@&sheet_id=%d", [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iStartMinute isDisplay:NO], [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iEndMinute isDisplay:NO], [TimeHandler convertNumberToDay:m_iPage], m_iSheetId];
    [m_oServerHandler makeRequest:@"time_action.php?action=DeleteTime" postData:sPostData action:@"EditTime"];
    
    if(m_fOldEndTime >= 0 && m_fOldStartTime >=0)
    {
        m_oCurrentTimeSlot.m_iStartMinute = m_fOldStartTime;
        m_oCurrentTimeSlot.m_iEndMinute = m_fOldEndTime;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    m_oErrorLabel.text = @"";
    
    CGFloat fNewMinutes = [self convertFromStringToMinutes:[dateFormatter stringFromDate:selectedTime]];
    CGFloat fOldMinutes;
    if(oButton.tag == START_TIME_BUTTON_TAG)
    {
        fOldMinutes = m_oCurrentTimeSlot.m_iStartMinute;
        if(fNewMinutes >= m_oCurrentTimeSlot.m_iEndMinute)
            return;
        if(m_oCurrentTimeSlot.m_iEndMinute - fNewMinutes < SMALLEST_TIME_SLOTSIZE)
        {
            m_oErrorLabel.text = [NSString stringWithFormat:@"Timeslot must be atleast %i minutes long", SMALLEST_TIME_SLOTSIZE];
            return;
        }
        m_fOldStartTime = m_oCurrentTimeSlot.m_iStartMinute;
        m_fOldEndTime = m_oCurrentTimeSlot.m_iEndMinute;
        m_oCurrentTimeSlot.m_iStartMinute = fNewMinutes;
    }
    else
    {
        fOldMinutes = m_oCurrentTimeSlot.m_iEndMinute;
        if(fNewMinutes <= m_oCurrentTimeSlot.m_iStartMinute)
            return;
        if(fNewMinutes - m_oCurrentTimeSlot.m_iStartMinute < SMALLEST_TIME_SLOTSIZE)
        {
            m_oErrorLabel.text = [NSString stringWithFormat:@"Timeslot must be atleast %i minutes long", SMALLEST_TIME_SLOTSIZE];
            return;
        }
        m_fOldStartTime = m_oCurrentTimeSlot.m_iStartMinute;
        m_fOldEndTime = m_oCurrentTimeSlot.m_iEndMinute;
        m_oCurrentTimeSlot.m_iEndMinute = fNewMinutes;
    }
    
    for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
    {
        if(oSavedSlot.tag == m_oCurrentTimeSlot.tag)
            continue;
        
        if([self doTimesOverlap:m_oCurrentTimeSlot otherTime:oSavedSlot])
        {
            if(oButton.tag == START_TIME_BUTTON_TAG)
                m_oCurrentTimeSlot.m_iStartMinute = fOldMinutes;
            else
                m_oCurrentTimeSlot.m_iEndMinute = fOldMinutes;
            return;
        }
    }
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    [oButton setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
    
    [m_oCurrentTimeSlot changeTimeSlot:CGRectMake(0, [self convertToPoints:m_oCurrentTimeSlot.m_iStartMinute] + TIME_PAGE_PADDING, m_oScrollView.bounds.size.width, [self convertToPoints:(m_oCurrentTimeSlot.m_iEndMinute - m_oCurrentTimeSlot.m_iStartMinute)])];
    
    if(oButton.tag == START_TIME_BUTTON_TAG)
        m_oCurrentTimeSlot.m_iStartMinute = fOldMinutes;
    else
        m_oCurrentTimeSlot.m_iEndMinute = fOldMinutes;

    if(oButton.tag == START_TIME_BUTTON_TAG)
        m_oCurrentTimeSlot.m_iStartMinute = fNewMinutes;
    else
        m_oCurrentTimeSlot.m_iEndMinute = fNewMinutes;
}

- (IBAction)clickDelete:(id)sender {
    m_bTimeEditorOpen = false;
    m_oTimeScroller.m_bDisabled = NO;
    [m_oTimeEditorPopupView removeFromSuperview];
    [m_oCurrentTimeSlot hideButtons];
    for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
    {
        if(oSavedSlot.tag == m_oCurrentTimeSlot.tag)
        {
            [m_oTimeSlots[m_iPage] removeObject:oSavedSlot];
            NSString *sPostData = [NSString stringWithFormat:@"time_slot=%@ %@ %@&sheet_id=%d", [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iStartMinute isDisplay:NO], [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iEndMinute isDisplay:NO], [TimeHandler convertNumberToDay:m_iPage], m_iSheetId];
            [m_oServerHandler makeRequest:@"time_action.php?action=DeleteTime" postData:sPostData action:@"EditTime"];
            [oSavedSlot removeFromSuperview];
            break;
        }
    }
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    if(m_bTimeEditorOpen) {
        return;
    }

    CGPoint oTouchPoint=[gesture locationInView:m_oScrollView];
    
    if(oTouchPoint.y >= TIME_PAGE_PADDING && oTouchPoint.y <= (TIME_PAGE_HEIGHT - TIME_PAGE_PADDING))
    {
        if(oTouchPoint.y >= (TIME_PAGE_HEIGHT - TIME_PAGE_PADDING - 60*m_fMinuteHeight))
            oTouchPoint.y = TIME_PAGE_HEIGHT - TIME_PAGE_PADDING - 60*m_fMinuteHeight;
        
        CGSize oScrollViewSize = m_oScrollView.bounds.size;
        TimeSlot *oTimeSlot  = [[TimeSlot alloc] initWithFrame:CGRectMake(0, oTouchPoint.y, oScrollViewSize.width, m_fMinuteHeight * DEFAULT_TIME_SLOTSIZE)];
        oTimeSlot.backgroundColor = [UIColor colorWithRed:162.0/255.0 green:222.0/255.0 blue:208.0/255.0 alpha:0.3f];
        oTimeSlot.m_oDelegate = self;
        oTimeSlot.tag = oTouchPoint.y;
        
        CGFloat fMinutes = [self convertToMinutes:oTouchPoint];
        oTimeSlot.m_iStartMinute = fMinutes;
        oTimeSlot.m_iEndMinute = fMinutes + DEFAULT_TIME_SLOTSIZE;
        
        for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
        {
            if([self doTimesOverlap:oTimeSlot otherTime:oSavedSlot])
                return;
        }
        
        m_oCurrentTimeSlot = oTimeSlot;
        [m_oStartTimeButton setTitle:[self convertFromMinutesToString:oTimeSlot.m_iStartMinute isDisplay:YES] forState:UIControlStateNormal];
        [m_oEndTimeButton setTitle:[self convertFromMinutesToString:oTimeSlot.m_iEndMinute isDisplay:YES] forState:UIControlStateNormal];
        
        [m_oTimeSlots[m_iPage] addObject:oTimeSlot];
        [m_oScrollView addSubview:oTimeSlot];
        [self.view addSubview:m_oTimeEditorPopupView];
        [oTimeSlot showButtons];
        
        m_oErrorLabel.text = @"";
        m_bTimeEditorOpen = true;
        m_oTimeScroller.m_bDisabled = YES;
        m_bIsNewSlot = true;
        m_fOldStartTime = -1;
        m_fOldEndTime = -1;
    }
}

#pragma mark Time-Point Calculation

- (CGFloat)convertToMinutes:(CGPoint)oPoint {
    return (oPoint.y - TIME_PAGE_PADDING)/(TIME_PAGE_HEIGHT - 2 * TIME_PAGE_PADDING) * (24 * 60);
}

- (CGFloat)convertToPoints:(CGFloat)fMinutes {
    return fMinutes * m_fMinuteHeight;
}

- (BOOL)doTimesOverlap:(TimeSlot *)oSlotA otherTime:(TimeSlot *)oSlotB {
    if(oSlotA.m_iStartMinute >= oSlotB.m_iStartMinute && oSlotA.m_iStartMinute <= oSlotB.m_iEndMinute)
        return YES;
    else if(oSlotA.m_iEndMinute >= oSlotB.m_iStartMinute && oSlotA.m_iEndMinute <= oSlotB.m_iEndMinute)
        return YES;
    else if(oSlotA.m_iStartMinute <= oSlotB.m_iStartMinute && oSlotA.m_iEndMinute >= oSlotB.m_iEndMinute)
        return YES;
    
    return NO;
}

- (NSString *)convertFromMinutesToString:(CGFloat)fMinutes isDisplay:(BOOL)bDisplay {
    int iHours = fMinutes/60;
    int iMinutes = fMinutes - iHours * 60;
    if(bDisplay)
    {
        NSString *sTimePart = @"AM";
        if(iHours == 0)
            iHours = 12;
        if(iHours > 12)
        {
            iHours = iHours - 12;
            sTimePart = @"PM";
        }
        return [NSString stringWithFormat:@"%02d:%02d %@", iHours, iMinutes, sTimePart];
    }
    else
        return [NSString stringWithFormat:@"%02d:%02d", iHours, iMinutes];
}

- (CGFloat)convertFromStringToMinutes:(NSString *)sTime {
    NSArray *oTimes = [sTime componentsSeparatedByString:@":"];
    return [oTimes[0] intValue]*60 + [oTimes[1] intValue];
}

#pragma mark Date Calculations
- (NSDate *)createDateFromMinutes:(int)iMinutes andHours:(int)iHours {
    NSCalendar *oCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [oCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:[NSDate date]];
    
    [components setHour:iHours];
    [components setMinute:iMinutes];
    
    return [oCalendar dateFromComponents:components];
}

- (int)convertDayToNumber:(NSString *)sDay {
    if([[sDay uppercaseString] isEqualToString:@"MON"])
        return 0;
    else if([[sDay uppercaseString] isEqualToString:@"TUE"])
        return 1;
    else if([[sDay uppercaseString] isEqualToString:@"WED"])
        return 2;
    else if([[sDay uppercaseString] isEqualToString:@"THU"])
        return 3;
    else if([[sDay uppercaseString] isEqualToString:@"FRI"])
        return 4;
    else if([[sDay uppercaseString] isEqualToString:@"SAT"])
        return 5;
    else
        return 6;
}

#pragma mark TimeScrollerDelegate

- (void)changedToDay:(int)iDay {
    [m_oTimeEditorPopupView removeFromSuperview];
    if(iDay != m_iPage)
    {
        for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
            [oSavedSlot removeFromSuperview];
    }
    m_iPage = iDay;
    [m_oTimeSlots[m_iPage] removeAllObjects];
    NSString *sListTimesUrl = [NSString stringWithFormat:@"time_action.php?action=ListTimes&sheet_id=%d", m_iSheetId];
    [m_oServerHandler makeRequest:sListTimesUrl postData:nil action:@"ListTimes"];
}

#pragma mark TimeSlotDelegate

- (void)clickSlot:(TimeSlot *)oTimeSlot {
    m_fOldStartTime = -1;
    m_fOldEndTime = -1;
    m_bIsNewSlot = false;
    m_oCurrentTimeSlot = oTimeSlot;
    m_oErrorLabel.text = @"";
    m_fOldStartTime = m_oCurrentTimeSlot.m_iStartMinute;
    m_fOldEndTime = m_oCurrentTimeSlot.m_iEndMinute;
    
    [self.view addSubview:m_oTimeEditorPopupView];
    [m_oCurrentTimeSlot showButtons];
    m_bTimeEditorOpen = true;
    m_oTimeScroller.m_bDisabled = YES;
    [m_oStartTimeButton setTitle:[self convertFromMinutesToString:oTimeSlot.m_iStartMinute isDisplay:YES] forState:UIControlStateNormal];
    [m_oEndTimeButton setTitle:[self convertFromMinutesToString:oTimeSlot.m_iEndMinute isDisplay:YES] forState:UIControlStateNormal];
}

- (void)upWasDragged:(CGPoint)oLocation {
    CGFloat fNewStart = [self convertToPoints:m_oCurrentTimeSlot.m_iStartMinute] + oLocation.y + TIME_PAGE_PADDING;
    fNewStart = [self convertToMinutes:CGPointMake(0, fNewStart)];
    if(fNewStart >= 0 && m_oCurrentTimeSlot.m_iEndMinute - fNewStart >= SMALLEST_TIME_SLOTSIZE)
    {
        CGFloat fOldMinutes = m_oCurrentTimeSlot.m_iStartMinute;
        m_oCurrentTimeSlot.m_iStartMinute = fNewStart;
        for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
        {
            if(oSavedSlot.tag == m_oCurrentTimeSlot.tag)
                continue;
            if([self doTimesOverlap:m_oCurrentTimeSlot otherTime:oSavedSlot])
            {
                m_oCurrentTimeSlot.m_iStartMinute = fOldMinutes;
                return;
            }
        }
        
        [m_oStartTimeButton setTitle:[self convertFromMinutesToString:m_oCurrentTimeSlot.m_iStartMinute isDisplay:YES] forState:UIControlStateNormal];
        [m_oCurrentTimeSlot changeTimeSlot:CGRectMake(0, [self convertToPoints:m_oCurrentTimeSlot.m_iStartMinute] + TIME_PAGE_PADDING, m_oScrollView.bounds.size.width, [self convertToPoints:(m_oCurrentTimeSlot.m_iEndMinute - m_oCurrentTimeSlot.m_iStartMinute)])];
    }
    
    if(([self convertToPoints:m_oCurrentTimeSlot.m_iStartMinute] - m_oScrollView.contentOffset.y)/self.view.frame.size.height < UP_SCROLL_THRESHOLD)
    {
        CGFloat fNewOffSet = m_oScrollView.contentOffset.y -  2 * m_fHourHeight;
        if(fNewOffSet < 0)
            fNewOffSet = 0;
        [m_oScrollView setContentOffset:CGPointMake(0, fNewOffSet) animated:YES];
    }
}

- (void)downWasDragged:(CGPoint)oLocation {
    CGFloat fNewEnd = [self convertToPoints:m_oCurrentTimeSlot.m_iEndMinute] + oLocation.y + TIME_PAGE_PADDING;
    fNewEnd = [self convertToMinutes:CGPointMake(0, fNewEnd)];
    if(fNewEnd <= 60*24 && fNewEnd - m_oCurrentTimeSlot.m_iStartMinute >= SMALLEST_TIME_SLOTSIZE)
    {
        CGFloat fOldMinutes = m_oCurrentTimeSlot.m_iEndMinute;
        m_oCurrentTimeSlot.m_iEndMinute = fNewEnd;
        for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
        {
            if(oSavedSlot.tag == m_oCurrentTimeSlot.tag)
                continue;
            if([self doTimesOverlap:m_oCurrentTimeSlot otherTime:oSavedSlot])
            {
                m_oCurrentTimeSlot.m_iEndMinute = fOldMinutes;
                return;
            }
        }
        
        [m_oEndTimeButton setTitle:[self convertFromMinutesToString:m_oCurrentTimeSlot.m_iEndMinute isDisplay:YES] forState:UIControlStateNormal];
        [m_oCurrentTimeSlot changeTimeSlot:CGRectMake(0, [self convertToPoints:m_oCurrentTimeSlot.m_iStartMinute] + TIME_PAGE_PADDING, m_oScrollView.bounds.size.width, [self convertToPoints:(m_oCurrentTimeSlot.m_iEndMinute - m_oCurrentTimeSlot.m_iStartMinute)])];
    }
    
    if(([self convertToPoints:m_oCurrentTimeSlot.m_iEndMinute] - m_oScrollView.contentOffset.y) / self.view.frame.size.height > DOWN_SCROLL_THRESHOLD)
    {
        CGFloat fNewOffSet = m_oScrollView.contentOffset.y +  2 * m_fHourHeight;
        if(fNewOffSet > TIME_PAGE_HEIGHT)
            fNewOffSet = TIME_PAGE_HEIGHT;
        [m_oScrollView setContentOffset:CGPointMake(0, fNewOffSet) animated:YES];
    }
}
#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ListTimes"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            NSArray *oTimeListModels = [TimeListModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            
            for(TimeListModel *oTimeListModel in oTimeListModels)
            {
                TimeSlot *oTimeSlot = [[TimeSlot alloc] init];
                oTimeSlot.m_iStartMinute = [self convertFromStringToMinutes:oTimeListModel.m_sStartTime];
                oTimeSlot.m_iEndMinute = [self convertFromStringToMinutes:oTimeListModel.m_sEndTime];
                oTimeSlot.frame = CGRectMake(0, [self convertToPoints:oTimeSlot.m_iStartMinute] + TIME_PAGE_PADDING, m_oScrollView.bounds.size.width, [self convertToPoints:(oTimeSlot.m_iEndMinute - oTimeSlot.m_iStartMinute)]);
                oTimeSlot.backgroundColor = [UIColor colorWithRed:162.0/255.0 green:222.0/255.0 blue:208.0/255.0 alpha:0.3f];
                oTimeSlot.m_oDelegate = self;
                oTimeSlot.tag = [self convertToPoints:oTimeSlot.m_iStartMinute];
                [oTimeSlot createButtons];
                
                [m_oTimeSlots[[self convertDayToNumber:oTimeListModel.m_sDay]] addObject:oTimeSlot];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for(TimeSlot *oSavedSlot in m_oTimeSlots[m_iPage])
                    [m_oScrollView addSubview:oSavedSlot];
            });
            
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"EditTime"])
    {
        NSString *sPostData = [NSString stringWithFormat:@"start_time=%@&end_time=%@&day=%@&sheet_id=%d", [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iStartMinute isDisplay:NO], [self convertFromMinutesToString:m_oCurrentTimeSlot.m_iEndMinute isDisplay:NO], [TimeHandler convertNumberToDay:m_iPage], m_iSheetId];
        [m_oServerHandler makeRequest:@"time_action.php?action=CreateTime" postData:sPostData action:@"CreateTime"];
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

@end
