//
//  UserProfileModel.m
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "UserProfileModel.h"

@implementation UserProfileModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"name"      : @"m_sName"     ,
                           @"user_name" : @"m_sUserName" ,
                           @"prof_img"  : @"m_sUserPic"  ,
                           @"is_friend" : @"m_sIsFriend" ,
                           @"number_meals_attended" : @"m_iNumberMealsAttended" ,
                           @"number_friends"        : @"m_iNumberFriends"       ,
                           @"number_meals_created"  : @"m_iNumberMealsCreated"  };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
