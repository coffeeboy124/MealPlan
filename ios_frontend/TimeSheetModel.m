//
//  TimeSheetModel.m
//  Mealplan
//
//  Created by Mao on 7/24/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "TimeSheetModel.h"

@implementation TimeSheetModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"sheet_id" : @"m_sId"    ,
                           @"name"     : @"m_sName"  ,
                           @"state"    : @"m_sState" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
