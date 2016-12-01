//
//  YelpAddress.m
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "YelpAddress.h"

@implementation YelpAddress

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"address"      : @"m_oAddress"    ,
                           @"city"         : @"m_sCity"       ,
                           @"postal_code"  : @"m_sPostalCode" ,
                           @"state_code"   : @"m_sStateCode"  ,
                           @"country_code" : @"m_sCountryCode"};
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
