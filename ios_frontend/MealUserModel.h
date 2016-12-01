//
//  MealUserModel.h
//  Mealplan
//
//  Created by Mao on 7/13/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface MealUserModel : JSONModel

@property (strong, nonatomic) NSString *m_sUserName;
@property (strong, nonatomic) NSString *m_sState;
@property (strong, nonatomic) NSString *m_sUserPic;

@end

@protocol MealUserModel

@end
