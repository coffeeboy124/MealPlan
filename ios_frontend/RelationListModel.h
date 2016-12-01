//
//  RelationListModel.h
//  Mealplan
//
//  Created by Mao on 7/8/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface RelationListModel : JSONModel

@property (strong, nonatomic) NSString *m_sUserName;
@property (strong, nonatomic) NSString *m_sState;
@property (strong, nonatomic) NSString *m_sUserPic;

//not part of the json response.
@property (strong, nonatomic) NSNumber<Optional> *m_oDidCheck;

@end

@protocol RelationListModel

@end
