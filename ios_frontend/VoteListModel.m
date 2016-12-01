//
//  VoteListModel.m
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "VoteListModel.h"

@implementation VoteListModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"user_name"       : @"m_sUserName"      ,
                           @"prof_pic"        : @"m_sUserPic"       ,
                           @"restaurant_id"   : @"m_sRestaurantId"  ,
                           @"restaurant_name" : @"m_sRestaurantName",
                           @"state"           : @"m_sState"         ,
                           @"id"              : @"m_sId"            };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
