//
//  RestaurantSelection_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "RestaurantSelection_ViewController.h"

@implementation RestaurantSelection_ViewController

@synthesize m_sToken;
@synthesize m_sZipCode;
@synthesize m_oServerHandler;
@synthesize m_oYelpListModels;
@synthesize m_oSearchBar;
@synthesize m_oTableView;
@synthesize m_oFooterView;
@synthesize m_iOffset;
@synthesize m_oActivityIndicator;
@synthesize m_oLocationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"icon_back.png"];
    
    UIBarButtonItem *oBackButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = oBackButton;
    
    UITapGestureRecognizer *oRemoveKeyboardGesture = [[UITapGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(dismissKeyboard)];
    oRemoveKeyboardGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:oRemoveKeyboardGesture];
    
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oYelpListModels = [[NSMutableArray alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_oTableView.dataSource = self;
    m_oTableView.delegate = self;
    m_oSearchBar.delegate = self;
    m_iOffset = 0;
    m_oSearchBar.tag = 1;
    [self initFooterView];
    m_oTableView.tableFooterView = m_oFooterView;
    m_oLocationManager =[[CLLocationManager alloc] init];
    m_oLocationManager.delegate = self;
    m_sZipCode = nil;
    
    UINib *oYelpCellNib = [UINib nibWithNibName:@"Yelp_TableViewCell" bundle:nil];
    [m_oTableView registerNib:oYelpCellNib forCellReuseIdentifier:@"Yelp_TableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    m_oLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [m_oLocationManager requestWhenInUseAuthorization];
    [m_oLocationManager startUpdatingLocation];
}

-(void) initFooterView {
    m_oFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    actInd.tag = 10;
    
    actInd.frame = CGRectMake(self.view.frame.size.width/2, 20.0, 20.0, 20.0);
    
    actInd.hidesWhenStopped = YES;
    
    [m_oFooterView addSubview:actInd];
    
    actInd = nil;
}

#pragma mark Click actions

- (void)clickBack {
    [self performSegueWithIdentifier:@"oRestaurantVotingSegue" sender:nil];
}

- (void)clickSuggest {
    Yelp_TableViewCell *oYelpCell;
    NSString *sPostData;
    YelpListModel *oYelpListModel;
    for (NSInteger j = 0; j < [m_oTableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [m_oTableView numberOfRowsInSection:j]; ++i)
        {
            oYelpCell = (Yelp_TableViewCell *)[m_oTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if(oYelpCell.m_oCheckButton.selected)
            {
                oYelpListModel = m_oYelpListModels[i];
                sPostData = [NSString stringWithFormat:@"token=%@&restaurant_id=%@&state=%@&restaurant_name=%@", m_sToken, oYelpListModel.m_sBusinessId, @"PROPOSED", oYelpListModel.m_sName];
                [m_oServerHandler makeRequest:@"/restaurant_action.php?action=CreateVote" postData:sPostData action:@"CreateVote"];
            }
        }
    }
    [self performSegueWithIdentifier:@"oRestaurantVotingSegue" sender:nil];
}

- (void)clickProposeButton:(UIButton *)oButton {
    YelpListModel *oYelpListModel = m_oYelpListModels[oButton.tag];
    NSString *sPostData = [NSString stringWithFormat:@"token=%@&restaurant_id=%@&state=%@&restaurant_name=%@", m_sToken, oYelpListModel.m_sBusinessId, @"PROPOSED", oYelpListModel.m_sName];
    [m_oServerHandler makeRequest:@"/restaurant_action.php?action=CreateVote" postData:sPostData action:@"CreateVote"];
    [self performSegueWithIdentifier:@"oRestaurantVotingSegue" sender:nil];
}

#pragma mark UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_oYelpListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Yelp_TableViewCell *oYelpCell = [tableView dequeueReusableCellWithIdentifier:@"Yelp_TableViewCell"];
    if(!oYelpCell)
        oYelpCell = [[Yelp_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Chat_TableViewCell"];
    
    YelpListModel *m_oYelpListModel = m_oYelpListModels[indexPath.row];
   
    
    NSURL *oProfilePicUrl = [NSURL URLWithString:m_oYelpListModel.m_sProfileUrl];
    [oYelpCell.m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:nil];
    NSURL *oRatingPicUrl = [NSURL URLWithString:m_oYelpListModel.m_sRatingUrl];
    [oYelpCell.m_oRatingImage sd_setImageWithURL:oRatingPicUrl placeholderImage:nil];
    oYelpCell.m_oNameLabel.text = m_oYelpListModel.m_sName;
    if (m_oYelpListModel.m_oAddress != nil && m_oYelpListModel.m_oAddress.m_oAddress.count > 0)
        oYelpCell.m_oAddressLabel.text = m_oYelpListModel.m_oAddress.m_oAddress[0];
    else
        oYelpCell.m_oAddressLabel.text = @"Address Unavailable";
   
    oYelpCell.m_oReviewsLabel.text = [NSString stringWithFormat:@"%d reviews on yelp", m_oYelpListModel.m_iReviewCount];
    oYelpCell.selectionStyle = UITableViewCellSelectionStyleNone;
    oYelpCell.m_oCheckButton.tag = indexPath.row;
    [oYelpCell.m_oCheckButton addTarget:self action:@selector(clickProposeButton:) forControlEvents:UIControlEventTouchUpInside];
    return oYelpCell;
}

#pragma mark UITableViewDataDelegate Protocol

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [m_oTableView deselectRowAtIndexPath: indexPath animated:YES];
    
    YelpListModel *oYelpListModel = m_oYelpListModels[indexPath.row];
    
    NSURL *oUrl = [[NSURL alloc] initWithString:oYelpListModel.m_sYelpUrl];
    if ([[UIApplication sharedApplication] canOpenURL:oUrl]) {
        [[UIApplication sharedApplication] openURL:oUrl];
    }
}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -40) {
        [(UIActivityIndicatorView *)[m_oFooterView viewWithTag:10] startAnimating];
        m_iOffset = m_iOffset + 1;
        if(m_oSearchBar.tag == 1)
        {
            if(m_sZipCode == nil)
                [m_oServerHandler queryTopBusinessInfoForTerm:@"Food" location:@"New York, NY" action:@"ListRestaurants" offset:m_iOffset];
            else
                [m_oServerHandler queryTopBusinessInfoForTerm:@"Food" location:m_sZipCode action:@"ListRestaurants" offset:m_iOffset];
        }
        else
        {
            if(m_sZipCode == nil)
                [m_oServerHandler queryTopBusinessInfoForTerm:m_oSearchBar.text location:@"New York, NY" action:@"ListRestaurants" offset:m_iOffset];
            else
                [m_oServerHandler queryTopBusinessInfoForTerm:m_oSearchBar.text location:m_sZipCode action:@"ListRestaurants" offset:m_iOffset];
        }
    }
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

- (void)processYelpResponseModel:(NSData *)oResponseData action:(NSString *)sAction {
    NSError *oJsonError;
    
    NSDictionary *oSearchResponseJSON = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:&oJsonError];
    NSArray *oBusinessArray = oSearchResponseJSON[@"businesses"];
    
    if([sAction isEqualToString:@"ListRestaurants"])
    {
        
        [m_oYelpListModels addObjectsFromArray:[YelpListModel arrayOfModelsFromDictionaries:oBusinessArray error:&oJsonError]];
        
        if (oJsonError) {
            NSLog(@"json error: %@", oJsonError.localizedDescription);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_oActivityIndicator stopAnimating];
            [(UIActivityIndicatorView *)[m_oFooterView viewWithTag:10] stopAnimating];
            [m_oTableView reloadData];
        });
    }
    return;
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    m_oSearchBar.tag = 0;
    m_iOffset = 0;
    [m_oYelpListModels removeAllObjects];
    if(m_sZipCode == nil)
        [m_oServerHandler queryTopBusinessInfoForTerm:searchBar.text location:@"New York, NY" action:@"ListRestaurants" offset:m_iOffset];
    else
        [m_oServerHandler queryTopBusinessInfoForTerm:searchBar.text location:m_sZipCode action:@"ListRestaurants" offset:m_iOffset];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
        m_oSearchBar.tag = 1;
        m_iOffset = 0;
        [m_oYelpListModels removeAllObjects];
        if(m_sZipCode == nil)
            [m_oServerHandler queryTopBusinessInfoForTerm:@"Food" location:@"New York, NY" action:@"ListRestaurants" offset:m_iOffset];
        else
            [m_oServerHandler queryTopBusinessInfoForTerm:@"Food" location:m_sZipCode action:@"ListRestaurants" offset:m_iOffset];
    }
}

- (void) dismissKeyboard
{
    [m_oSearchBar resignFirstResponder];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController* oErrorAlert = [UIAlertController alertControllerWithTitle:@"Access Denied!" message:@"Please enable locations. Settings > MealPlan > Location. Default Location is NYC" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* oDefaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [oErrorAlert addAction:oDefaultAction];
    [self presentViewController:oErrorAlert animated:YES completion:nil];

    [m_oLocationManager stopUpdatingLocation];
    [m_oServerHandler queryTopBusinessInfoForTerm:@"Food" location:@"New York, NY" action:@"ListRestaurants" offset:m_iOffset];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *oCurrentLocation = [locations lastObject];
    
    if (oCurrentLocation != nil) {
        [self performCoordinateGeocode:oCurrentLocation];
        [m_oLocationManager stopUpdatingLocation];
    }
}

#pragma mark - Utility

- (IBAction)performCoordinateGeocode:(CLLocation *)oLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:oLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *oPlacemark = [placemarks objectAtIndex:0];
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        m_sZipCode = oPlacemark.postalCode;
        [m_oServerHandler queryTopBusinessInfoForTerm:@"Food" location:m_sZipCode action:@"ListRestaurants" offset:m_iOffset];
    }];
}
@end
