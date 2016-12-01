//
//  RelationListModel.h
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface UserProfileModel : JSONModel

@property (strong, nonatomic) NSString *m_sName;
@property (strong, nonatomic) NSString *m_sUserName;
@property (strong, nonatomic) NSString *m_sUserPic;
@property (strong, nonatomic) NSString *m_sIsFriend;
@property (assign, nonatomic) int m_iNumberMealsAttended;
@property (assign, nonatomic) int m_iNumberFriends;
@property (assign, nonatomic) int m_iNumberMealsCreated;

@end

@protocol UserProfileModel

@end
