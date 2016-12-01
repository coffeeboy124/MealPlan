//
//  TimeListModel.m
//  Mealplan
//
//  Created by Mao on 7/11/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "TimeListModel.h"

@implementation TimeListModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"start_time" : @"m_sStartTime",
                           @"end_time"   : @"m_sEndTime"  ,
                           @"day"        : @"m_sDay"      };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
