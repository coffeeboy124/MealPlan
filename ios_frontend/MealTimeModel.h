//
//  MealTimeModel.h
//  Mealplan
//
//  Created by Mao on 7/13/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"
#import "TimeListModel.h"
#import "MealUserModel.h"

@interface MealTimeModel : JSONModel

@property (strong, nonatomic) TimeListModel *m_oTimeSlot;
@property (strong, nonatomic) NSArray<MealUserModel> *m_oUsers;

@end

@protocol MealTimeModel

@end