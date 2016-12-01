//
//  TimeSheets_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/10/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "TimeSheets_ViewController.h"

@implementation TimeSheets_ViewController

@synthesize m_oTimeSheetModels;
@synthesize m_oServerHandler;
@synthesize m_iCurrentSheetId;
@synthesize m_oTableView;
@synthesize m_iCurrentSheetTag;
@synthesize m_oErrorLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oTimeSheetModels = [[NSMutableArray alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_oTableView.delegate = self;
    m_oTableView.dataSource = self;
    m_iCurrentSheetId = -1;
    m_oErrorLabel.text = @"";
    
    UINib *oSelectCellNib = [UINib nibWithNibName:@"TimeSheet_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oSelectCellNib forCellReuseIdentifier:@"TimeSheet_TableViewCell"];
    UINib *oSectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [m_oTableView registerNib:oSectionHeaderNib forHeaderFooterViewReuseIdentifier:@"SectionHeader"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [m_oServerHandler makeRequest:@"/time_action.php?action=ListTimeSheets" postData:nil action:@"ListTimeSheets"];
}

#pragma mark Navigation

- (IBAction)unwindToTimeSheets:(UIStoryboardSegue *)segue {
    return;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"oTimeEditorSegue"]) {
        TimeEditor_ViewController *oTimeEditor_ViewController = (TimeEditor_ViewController *) [segue destinationViewController];
        oTimeEditor_ViewController.m_iSheetId = m_iCurrentSheetId;
    }
}

#pragma mark Click actions

- (IBAction)clickNewSchedule:(id)oSender {
    NSString *sTemporarySheetName = @"New Schedule";
    int i = 1;
    for(TimeSheetModel *oTimeSheetModel in m_oTimeSheetModels)
    {
        if([oTimeSheetModel.m_sName caseInsensitiveCompare:[NSString stringWithFormat:@"%@ %d", sTemporarySheetName, i]] == NSOrderedSame)
            i++;
    }
    NSString *sPostData = [NSString stringWithFormat:@"name=%@", [NSString stringWithFormat:@"%@ %d", sTemporarySheetName, i]];
    [m_oServerHandler makeRequest:@"/time_action.php?action=CreateTimeSheet" postData:sPostData action:@"CreateTimeSheet"];
}

- (IBAction)clickEditSpecificDates:(id)sender {
}

- (void)clickDeleteButton:(UIButton *)oButton {
    TimeSheetModel *oTimeSheetModel = m_oTimeSheetModels[oButton.tag];
    
    NSString *sDeleteTimeSheet = [NSString stringWithFormat:@"/time_action.php?action=DeleteTimeSheet&sheet_id=%@", oTimeSheetModel.m_sId];
    [m_oServerHandler makeRequest:sDeleteTimeSheet postData:nil action:@"DeleteTimeSheet"];
    
    m_iCurrentSheetTag = (int)oButton.tag;
}

- (void)clickEditButton:(UIButton *)oButton {
    [self.tabBarController.tabBar setHidden:YES];
    TimeSheetModel *oTimeSheetModel = m_oTimeSheetModels[oButton.tag];
    m_iCurrentSheetId = [oTimeSheetModel.m_sId intValue];
    [self performSegueWithIdentifier:@"oTimeEditorSegue" sender:nil];
}

- (void)clickSetActiveButton:(UIButton *)oButton {
    TimeSheetModel *oTimeSheetModel = m_oTimeSheetModels[oButton.tag];
    
    NSString *sSetActiveTimeSheetUrl = [NSString stringWithFormat:@"/time_action.php?action=SetActiveSheet&sheet_id=%@", oTimeSheetModel.m_sId];
    [m_oServerHandler makeRequest:sSetActiveTimeSheetUrl postData:nil action:@"SetActiveTimeSheet"];
    
    TimeSheet_TableViewCell *oTimeSheetCell;
    for (NSInteger j = 0; j < [m_oTableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [m_oTableView numberOfRowsInSection:j]; ++i)
        {
            oTimeSheetCell = (TimeSheet_TableViewCell *)[m_oTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if(i == oButton.tag)
            {
                oTimeSheetModel = m_oTimeSheetModels[i];
                oTimeSheetModel.m_sState = @"ACTIVE";
                oTimeSheetCell.m_oIsActiveImage.hidden = NO;
            }
            else
            {
                oTimeSheetModel = m_oTimeSheetModels[i];
                oTimeSheetModel.m_sState = @"INACTIVE";
                oTimeSheetCell.m_oIsActiveImage.hidden = YES;
            }
        }
    }
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_oTimeSheetModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TimeSheet_TableViewCell *oTimeSheetCell = [tableView dequeueReusableCellWithIdentifier:@"TimeSheet_TableViewCell"];
    if(!oTimeSheetCell)
        oTimeSheetCell = [[TimeSheet_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TimeSheet_TableViewCell"];
    
    TimeSheetModel *oTimeSheetModel = m_oTimeSheetModels[indexPath.row];
    oTimeSheetCell.m_oNameField.text = oTimeSheetModel.m_sName;
    if([oTimeSheetModel.m_sState isEqualToString:@"INACTIVE"])
        oTimeSheetCell.m_oIsActiveImage.hidden = YES;
    else
        oTimeSheetCell.m_oIsActiveImage.hidden = NO;
    
    oTimeSheetCell.m_oNameField.delegate = self;
    oTimeSheetCell.m_oRenameButton.userInteractionEnabled = NO;
    oTimeSheetCell.selectionStyle = UITableViewCellSelectionStyleNone;
    oTimeSheetCell.m_oDeleteButton.tag = indexPath.row;
    oTimeSheetCell.m_oEditButton.tag = indexPath.row;
    oTimeSheetCell.m_oSetActiveButton.tag = indexPath.row;
    oTimeSheetCell.m_oNameField.tag = indexPath.row;
    [oTimeSheetCell.m_oDeleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [oTimeSheetCell.m_oEditButton addTarget:self action:@selector(clickEditButton:) forControlEvents:UIControlEventTouchUpInside];
    [oTimeSheetCell.m_oSetActiveButton addTarget:self action:@selector(clickSetActiveButton:) forControlEvents:UIControlEventTouchUpInside];

    return oTimeSheetCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionHeaderView *oSectionHeaderView = [m_oTableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionHeader"];
    
    if (!oSectionHeaderView) {
        oSectionHeaderView = [[SectionHeaderView alloc] initWithReuseIdentifier:@"SectionHeader"];
    }
    
    oSectionHeaderView.m_oExpandButton.hidden = YES;
    oSectionHeaderView.m_oIconImage.hidden = YES;
    oSectionHeaderView.m_oNameLabel.text = @"Time Sheets";
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
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TimeSheet_TableViewCell *oTimeSheetCell = (TimeSheet_TableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [oTimeSheetCell.m_oNameField becomeFirstResponder];
}


#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ListTimeSheets"])
    {
        NSError *oJsonError;
        NSArray *oJsonValues = [NSJSONSerialization JSONObjectWithData:[oServerResponseModel.m_sOutput dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&oJsonError];
        
        if (!oJsonError)
        {
            [m_oTimeSheetModels removeAllObjects];
            m_oTimeSheetModels = [TimeSheetModel arrayOfModelsFromDictionaries:oJsonValues error:&oJsonError];
            
            if(oJsonError)
            {
                NSLog(@"json error: %@", oJsonError.localizedDescription);
                return;
            }
            
            if(m_oTimeSheetModels.count == 1)
            {
                TimeSheetModel *oTimeSheetModel = m_oTimeSheetModels[0];
                oTimeSheetModel.m_sState = @"ACTIVE";
                NSString *sSetActiveTimeSheetUrl = [NSString stringWithFormat:@"/time_action.php?action=SetActiveSheet&sheet_id=%@", oTimeSheetModel.m_sId];
                [m_oServerHandler makeRequest:sSetActiveTimeSheetUrl postData:nil action:@"SetActiveTimeSheet"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_oTableView reloadData];
            });
            return;
        }
        NSLog(@"json error: %@", oJsonError.localizedDescription);
        return;
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"CreateTimeSheet"])
    {
        [m_oTimeSheetModels removeAllObjects];
        [m_oServerHandler makeRequest:@"/time_action.php?action=ListTimeSheets" postData:nil action:@"ListTimeSheets"];
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"DeleteTimeSheet"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            m_oErrorLabel.text = @"";
            [m_oTimeSheetModels removeObjectAtIndex:m_iCurrentSheetTag];
            [m_oTableView reloadData];
        });
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"FALSE"] && [sAction isEqualToString:@"DeleteTimeSheet"])
    {
        m_oErrorLabel.text = @"Cant delete timesheet that is being used in an ongoing meal";
    }

    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

#pragma mark UITextFieldDelegate Protocol

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    TimeSheetModel *oTimeSheetModel = m_oTimeSheetModels[textField.tag];
    NSString *sPostData = [NSString stringWithFormat:@"name=%@&sheet_id=%@", textField.text, oTimeSheetModel.m_sId];
    [m_oServerHandler makeRequest:@"/time_action.php?action=ChangeSheetName" postData:sPostData action:@"ChangeSheetName"];
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 32;
}
@end