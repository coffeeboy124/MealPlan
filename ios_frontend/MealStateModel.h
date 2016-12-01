//
//  MealStateModel.h
//  Mealplan
//
//  Created by Mao on 8/16/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface MealStateModel : JSONModel

@property (strong, nonatomic) NSString *m_sMealState;
@property (strong, nonatomic) NSString *m_sTimeSlot;
@property (strong, nonatomic) NSString *m_sRestaurantName;
@property (strong, nonatomic) NSString *m_sRestaurantLocation;

@end

@protocol MealStateModel

@end