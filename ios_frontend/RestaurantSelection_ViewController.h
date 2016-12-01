//
//  RestaurantSelection_ViewController.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ServerHandler.h"
#import "NSURLRequest+OAuth.h"
#import "YelpListModel.h"
#import "Yelp_TableViewCell.h"
#import <CoreLocation/CoreLocation.h>

@interface RestaurantSelection_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ServerHandlerDelegate, UISearchBarDelegate,  CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *m_sToken;
@property (strong, nonatomic) NSString *m_sZipCode;
@property (strong, nonatomic) ServerHandler *m_oServerHandler;
@property (strong, nonatomic) NSMutableArray *m_oYelpListModels;
@property (strong, nonatomic) UIView *m_oFooterView;
@property (assign, nonatomic) int m_iOffset;
@property (weak, nonatomic) IBOutlet UISearchBar *m_oSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *m_oTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_oActivityIndicator;

@property CLLocationManager *m_oLocationManager;

@end
