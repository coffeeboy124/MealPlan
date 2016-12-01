//
//  YelpListModel.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"
#import "YelpAddress.h"

@interface YelpListModel : JSONModel

@property (strong, nonatomic) NSString *m_sName;
@property (strong, nonatomic) YelpAddress<Optional> *m_oAddress;
@property (strong, nonatomic) NSString<Optional> *m_sBusinessId;
@property (strong, nonatomic) NSString<Optional> *m_sRatingUrl;
@property (strong, nonatomic) NSString<Optional> *m_sProfileUrl;
@property (strong, nonatomic) NSString<Optional> *m_sYelpUrl;
@property (assign, nonatomic) int m_iReviewCount;
@property (assign, nonatomic) float m_fRating;

@end

@protocol YelpListModel

@end
