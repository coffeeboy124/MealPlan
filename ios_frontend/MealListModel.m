//
//  MealListModel.m
//  Mealplan
//
//  Created by Mao on 7/6/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MealListModel.h"

@implementation MealListModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"meal_state" : @"m_sMealState" ,
                           @"token"      : @"m_sToken"     ,
                           @"meal_name"  : @"m_sMealName"  ,
                           @"user_name"  : @"m_sUserName"  ,
                           @"user_state" : @"m_sUserState" ,
                           @"prof_img"   : @"m_sUserPic"   ,
                           @"attendance" : @"m_sAttendance"};
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
