//
//  MealStateModel.m
//  Mealplan
//
//  Created by Mao on 8/16/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MealStateModel.h"

@implementation MealStateModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"meal_state"          : @"m_sMealState"         ,
                           @"meal_time_slot"      : @"m_sTimeSlot"          ,
                           @"restaurant_name"     : @"m_sRestaurantName"    ,
                           @"restaurant_location" : @"m_sRestaurantLocation"};
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
