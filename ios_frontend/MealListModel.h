//
//  MealListModel.h
//  Mealplan
//
//  Created by Mao on 7/6/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface MealListModel : JSONModel

@property (strong, nonatomic) NSString *m_sMealState;
@property (strong, nonatomic) NSString *m_sToken;
@property (strong, nonatomic) NSString *m_sMealName;
@property (strong, nonatomic) NSString *m_sUserName;
@property (strong, nonatomic) NSString *m_sUserState;
@property (strong, nonatomic) NSString *m_sUserPic;
@property (strong, nonatomic) NSString *m_sAttendance;

@end

@protocol MealListModel

@end