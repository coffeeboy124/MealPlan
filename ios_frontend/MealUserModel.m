//
//  MealUserModel.m
//  Mealplan
//
//  Created by Mao on 7/13/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MealUserModel.h"

@implementation MealUserModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"user_name" : @"m_sUserName",
                           @"state"     : @"m_sState"   ,
                           @"prof_img"  : @"m_sUserPic" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
