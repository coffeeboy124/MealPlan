//
//  ServerResponseModel.m
//  Mealplan
//
//  Created by Mao on 7/3/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "ServerResponseModel.h"

@implementation ServerResponseModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"Result" : @"m_sResult",
                           @"Error"  : @"m_sError" ,
                           @"Output" : @"m_sOutput",
                           };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
