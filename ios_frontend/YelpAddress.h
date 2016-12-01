//
//  YelpAddress.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface YelpAddress : JSONModel

@property (strong, nonatomic) NSArray<Optional>  *m_oAddress;
@property (strong, nonatomic) NSString<Optional> *m_sCity;
@property (strong, nonatomic) NSString<Optional> *m_sPostalCode;
@property (strong, nonatomic) NSString<Optional> *m_sStateCode;
@property (strong, nonatomic) NSString<Optional> *m_sCountryCode;

@end

@protocol YelpAddress

@end