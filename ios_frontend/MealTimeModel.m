//
//  MealTimeModel.m
//  Mealplan
//
//  Created by Mao on 7/13/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MealTimeModel.h"

@implementation MealTimeModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"time_slot" : @"m_oTimeSlot",
                           @"meal_user" : @"m_oUsers"   };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
