//
//  YelpListModel.m
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "YelpListModel.h"

@implementation YelpListModel

+ (JSONKeyMapper*)keyMapper {
    NSDictionary *map = @{ @"name"           : @"m_sName"       ,
                           @"location"       : @"m_oAddress"    ,
                           @"id"             : @"m_sBusinessId" ,
                           @"rating_img_url" : @"m_sRatingUrl"  ,
                           @"image_url"      : @"m_sProfileUrl" ,
                           @"mobile_url"     : @"m_sYelpUrl"    ,
                           @"review_count"   : @"m_iReviewCount",
                           @"rating"         : @"m_fRating"     };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

@end
