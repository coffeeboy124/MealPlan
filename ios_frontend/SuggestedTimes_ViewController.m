//
//  SuggestedTimes_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/13/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "SuggestedTimes_ViewController.h"

@implementation SuggestedTimes_ViewController

@synthesize m_bIsHost;
@synthesize m_iCollectionViewIndex;
@synthesize m_oCurrentMealUserModel;
@synthesize m_sToken;
@synthesize m_oMealUserModels;
@synthesize m_oExcludedMealUserModels;
@synthesize m_oMealTimeModels;
@synthesize m_oServerHandler;
@synthesize m_oCollectionView;
@synthesize m_oTableView;
@synthesize m_oDateLabel;
@synthesize m_oStartTimeButton;
@synthesize m_oEndTimeButton;
@synthesize m_oStartTimeLabel;
@synthesize m_oEndTimeLabel;
@synthesize m_oAttendingLabel;

#define START_TIME_BUTTON_TAG 0
#define END_TIME_BUTTON_TAG 1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"icon_back.png"];
    
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;
    
    m_oExcludedMealUserModels = [[NSMutableArray alloc] init];
    m_oMealTimeModels = [[NSMutableArray alloc] init];
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_oCollectionView.dataSource = self;
    m_oCollectionView.delegate = self;
    m_oCollectionView.backgroundColor = [UIColor clearColor];
    m_iCollectionViewIndex = -1;
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [m_oStartTimeButton addTarget:self action:@selector(clickTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    [m_oEndTimeButton addTarget:self action:@selector(clickTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    m_oStartTimeButton.tag = START_TIME_BUTTON_TAG;
    m_oEndTimeButton.tag = END_TIME_BUTTON_TAG;
    m_oStartTimeButton.enabled = NO;
    m_oEndTimeButton.enabled = NO;
    
    UINib *oBreakfastCellNib = [UINib nibWithNibName:@"Breakfast_MealTime" bundle:nil];
    [m_oCollectionView registerNib:oBreakfastCellNib forCellWithReuseIdentifier:@"BreakfastTime_Cell"];
    UINib *oLunchCellNib = [UINib nibWithNibName:@"Lunch_MealTime" bundle:nil];
    [m_oCollectionView registerNib:oLunchCellNib forCellWithReuseIdentifier:@"LunchTime_Cell"];
    UINib *oDinnerCellNib = [UINib nibWithNibName:@"Dinner_MealTime" bundle:nil];
    [m_oCollectionView registerNib:oDinnerCellNib forCellWithReuseIdentifier:@"DinnerTime_Cell"];
    UINib *oUnknownCellNib = [UINib nibWithNibName:@"Unknown_MealTime" bundle:nil];
    [m_oCollectionView registerNib:oUnknownCellNib forCellWithReuseIdentifier:@"UnknownTime_Cell"];
    UINib *oPersonCellNib = [UINib nibWithNibName:@"Person_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oPersonCellNib forCellReuseIdentifier:@"Person_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    NSString *sViewMealTimesUrl = [NSString stringWithFormat:@"/meal_action.php?action=ViewMealTimes&token=%@", m_sToken];
    [m_oServerHandler makeRequest:sViewMealTimesUrl postData:nil action:@"ViewMealTimes"];
}

#pragma mark Navigation

- (IBAction)unwindToSuggestedTimes:(UIStoryboardSegue *)segue {
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oSuggestedTimesViewProfileSegue"]) {
        ViewProfile_ViewController *oViewProfile_ViewController = (ViewProfile_ViewController *) [segue destinationViewController];
        oViewProfile_ViewController.m_sSearchedUserName = m_oCurrentMealUserModel.m_sUserName;
        oViewProfile_ViewController.m_sBackSegue = @"oSuggestedTimesSegue";
    }
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if(m_oMealTimeModels.count > 0)
        m_oDateLabel.text = @"Select a Time Slot";
    else if(m_oMealTimeModels.count > 0)
        m_oDateLabel.text = @"No Times";
    return m_oMealTimeModels.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /*install breakfast, lunch, dinner, and unknown times*/
    Time_CollectionViewCell *oTimeCell;
    MealTimeModel *oMealTimeModel = m_oMealTimeModels[indexPath.row];
    NSArray *oTimes = [oMealTimeModel.m_oTimeSlot.m_sStartTime componentsSeparatedByString:@":"];
    if([oTimes[0] integerValue] < 6)
        oTimeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UnknownTime_Cell" forIndexPath:indexPath];
    else if([oTimes[0] integerValue] < 11)
        oTimeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BreakfastTime_Cell" forIndexPath:indexPath];
    else if([oTimes[0] integerValue] < 17)
        oTimeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LunchTime_Cell" forIndexPath:indexPath];
    else
        oTimeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DinnerTime_Cell" forIndexPath:indexPath];
    
    oTimeCell.m_oTimeListModel = oMealTimeModel.m_oTimeSlot;
    [oTimeCell setLabels];
    return oTimeCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [m_oExcludedMealUserModels removeAllObjects];
    m_iCollectionViewIndex = (int) indexPath.row;
    MealTimeModel *oMealTimeModel = m_oMealTimeModels[m_iCollectionViewIndex];
    Time_CollectionViewCell *oTimeCell = [[Time_CollectionViewCell alloc] init];
    oTimeCell.m_oTimeListModel = oMealTimeModel.m_oTimeSlot;
    m_oDateLabel.text = [oTimeCell getDateText];
    m_oStartTimeLabel.text = @"Start time:";
    m_oEndTimeLabel.text = @"End time:";
    [m_oStartTimeButton setTitle:[self convertTimeString:oMealTimeModel.m_oTimeSlot.m_sStartTime] forState:UIControlStateNormal];
    [m_oEndTimeButton setTitle:[self convertTimeString:oMealTimeModel.m_oTimeSlot.m_sEndTime] forState:UIControlStateNormal];
    m_oStartTimeButton.enabled = YES;
    m_oEndTimeButton.enabled = YES;
    m_oAttendingLabel.text = [NSString stringWithFormat:@"Attending: %lu/%lu", (unsigned long)oMealTimeModel.m_oUsers.count, (unsigned long)m_oMealUserModels.count];
    
    for(MealUserModel *oMealUserModel in m_oMealUserModels)
    {
        BOOL bShouldAdd = true;
        for(MealUserModel *oMealUserModelCmp in oMealTimeModel.m_oUsers)
        {
            if([oMealUserModel.m_sUserName isEqualToString:oMealUserModelCmp.m_sUserName])
            {
                bShouldAdd = false;
                break;
            }
        }
        if(bShouldAdd)
           [m_oExcludedMealUserModels addObject:oMealUserModel];
    }
    [m_oTableView reloadData];
}


#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (m_iCollectionViewIndex == -1)
        return 0;
    MealTimeModel *oMealTimeModel = m_oMealTimeModels[m_iCollectionViewIndex];
    if(section == 0)
        return oMealTimeModel.m_oUsers.count;
    else
        return m_oMealUserModels.count - oMealTimeModel.m_oUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Person_TableViewCell *oPersonCell = [tableView dequeueReusableCellWithIdentifier:@"Person_TableViewCell"];
    if(!oPersonCell)
        oPersonCell = [[Person_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Person_TableViewCell"];
    
    MealTimeModel *oMealTimeModel = m_oMealTimeModels[m_iCollectionViewIndex];
    MealUserModel *oMealUserModel;
    
    if(indexPath.section == 0)
        oMealUserModel = oMealTimeModel.m_oUsers[indexPath.row];
    else
        oMealUserModel = m_oExcludedMealUserModels[indexPath.row];
    
    NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oMealUserModel.m_sUserPic]];
    UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
    [oPersonCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
    oPersonCell.m_oUserNameLabel.text = oMealUserModel.m_sUserName;
    oPersonCell.m_oButton.hidden = YES;
    if([oMealUserModel.m_sState isEqualToString:@"HOST"])
    {
        oPersonCell.m_oButton.hidden = NO;
        oPersonCell.m_oButton.enabled = NO;
    }
    oPersonCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return oPersonCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    if(section == 0)
        oSectionHeaderView.m_oNameLabel.text = @"Attending";
    else
        oSectionHeaderView.m_oNameLabel.text = @"Not Attending";
    oSectionHeaderView.m_oExpandButton.hidden = YES;
    oSectionHeaderView.m_oIconImage.hidden = YES;
    return oSectionHeaderView;
}

#pragma mark UITableViewDataDelegate Protocol

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
    {
        MealTimeModel *oMealTimeModel = m_oMealTimeModels[m_iCollectionViewIndex];
        m_oCurrentMealUserModel = oMealTimeModel.m_oUsers[indexPath.row];
        [self performSegueWithIdentifier:@"oSuggestedTimesViewProfileSegue" sender:nil];
    }
}

#pragma mark Click actions

- (void)clickBack {
    [self performSegueWithIdentifier:@"oMealSummarySegue" sender:nil];
}

- (IBAction)clickConfirm:(id)sender {
    if(m_iCollectionViewIndex != -1)
    {
        NSString *sPostData = [NSString stringWithFormat:@"token=%@&time_slot=%@", m_sToken, [NSString stringWithFormat:@"%@ | %@ - %@", m_oDateLabel.text, [m_oStartTimeButton.currentTitle stringByReplacingOccurrencesOfString:@" " withString:@""], [m_oEndTimeButton.currentTitle stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        NSString *sSelectTimeUrl = [NSString stringWithFormat:@"/meal_action.php?action=SelectTime"];
        [m_oServerHandler makeRequest:sSelectTimeUrl postData:sPostData action:@"SelectTime"];
    }
    [self performSegueWithIdentifier:@"oMealSummarySegue" sender:nil];
}

- (void)clickTimeButton:(id)sender {
    UIButton *oButton = (UIButton *)sender;
    NSArray *oTimes = [self convertFromTimeToHoursAndMinutes:oButton.currentTitle];
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:[self createDateFromMinutes:[oTimes[1] intValue] andHours:[oTimes[0] intValue]] target:self action:@selector(timeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = 1;
    [datePicker showActionSheetPicker];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(UIButton *)oButton {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    CGFloat fNewMinutes = [self convertFromStringToMinutes:[dateFormatter stringFromDate:selectedTime]];
    MealTimeModel *oMealTimeModel = m_oMealTimeModels[m_iCollectionViewIndex];
    if(fNewMinutes < [self convertFromStringToMinutes:oMealTimeModel.m_oTimeSlot.m_sStartTime] || fNewMinutes > [self convertFromStringToMinutes:oMealTimeModel.m_oTimeSlot.m_sEndTime])
        return;
    if(oButton.tag == START_TIME_BUTTON_TAG) //start time button
    {
        NSArray *oTimes = [self convertFromTimeToHoursAndMinutes:m_oEndTimeButton.currentTitle];
        if(fNewMinutes > ([oTimes[0] intValue]*60 + [oTimes[1] intValue]))
            return;
    }
    else //end time button
    {
        NSArray *oTimes = [self convertFromTimeToHoursAndMinutes:m_oStartTimeButton.currentTitle];
        if(fNewMinutes < ([oTimes[0] intValue]*60 + [oTimes[1] intValue]))
            return;
    }
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    [oButton setTitle:[dateFormatter stringFromDate:selectedTime] forState:UIControlStateNormal];
}

#pragma mark ServerHandlerDelegate

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ViewMealTimes"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oMealTimeModels removeAllObjects];
            m_oMealTimeModels = [MealTimeModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            
            /*Step 1: group all times by number of people attending*/
            NSMutableArray *oSizeBuckets = [[NSMutableArray alloc] init];
            for(MealTimeModel* oMealTimeModel in m_oMealTimeModels)
            {
                bool doAdd = false;
                for(NSMutableArray *oArray in oSizeBuckets)
                {
                    if(oMealTimeModel.m_oUsers.count == ((MealTimeModel*) oArray[0]).m_oUsers.count)
                    {
                        doAdd = true;
                        [oArray addObject:oMealTimeModel];
                        break;
                    }
                }
                if(!doAdd)
                {
                    NSMutableArray *oBucketArray = [[NSMutableArray alloc] init];
                    [oBucketArray addObject:oMealTimeModel];
                    [oSizeBuckets addObject:oBucketArray];
                }
            }
            /*Step 2: Sort all buckets by size order*/
            oSizeBuckets = [NSMutableArray arrayWithArray:[oSizeBuckets sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = [NSNumber numberWithLong:((NSMutableArray*) a).count];
                NSNumber *second = [NSNumber numberWithLong:((NSMutableArray*) b).count];
                return [first compare:second];
            }]];
            /*Step 3: Sort all internal buckets by time order and then put them into the array*/
            [m_oMealTimeModels removeAllObjects];
            for(NSMutableArray *oArray in oSizeBuckets)
            {
                NSMutableArray *oTemp = [NSMutableArray arrayWithArray:[oArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate *first = [TimeHandler findDate:((MealTimeModel*) a).m_oTimeSlot.m_sDay];
                    NSDate *second = [TimeHandler findDate:((MealTimeModel*) b).m_oTimeSlot.m_sDay];
                    return [first compare:second];
                }]];
                for(MealTimeModel* oMealTimeModel in oTemp)
                    [m_oMealTimeModels addObject:oMealTimeModel];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_oCollectionView reloadData];
            });
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

#pragma mark Time Utilities

- (NSString *)convertTimeString:(NSString *)sTime {
    NSArray *oTimes = [sTime componentsSeparatedByString:@":"];
    if([oTimes[0] intValue] == 0)
        return [NSString stringWithFormat:@"%02d:%02d %@", 12, [oTimes[1] intValue], @"AM"];
    if([oTimes[0] intValue] > 12)
        return [NSString stringWithFormat:@"%02d:%02d %@", [oTimes[0] intValue] - 12, [oTimes[1] intValue], @"PM"];
    return [NSString stringWithFormat:@"%02d:%02d %@", [oTimes[0] intValue], [oTimes[1] intValue], @"AM"];
}

- (NSDate *)createDateFromMinutes:(int)iMinutes andHours:(int)iHours {
    NSCalendar *oCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [oCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:[NSDate date]];
    
    [components setHour:iHours];
    [components setMinute:iMinutes];
    
    return [oCalendar dateFromComponents:components];
}

- (CGFloat)convertFromStringToMinutes:(NSString *)sTime {
    NSArray *oTimes = [sTime componentsSeparatedByString:@":"];
    return [oTimes[0] intValue]*60 + [oTimes[1] intValue];
}

- (NSArray *)convertFromTimeToHoursAndMinutes:(NSString *)sTime {
    NSArray *oTimes = [sTime componentsSeparatedByString:@":"];
    NSArray *oTimes2 = [oTimes[1] componentsSeparatedByString:@" "];
    int iHours = [oTimes[0] intValue];
    int iMinutes = [oTimes2[0] intValue];
    if([oTimes2[1] isEqualToString:@"PM"])
        iHours = iHours + 12;
    if([oTimes2[1] isEqualToString:@"AM"] && iHours == 12)
        iHours = 0;
    
    return @[[NSNumber numberWithInt:iHours], [NSNumber numberWithInt:iMinutes]];
}


@end
