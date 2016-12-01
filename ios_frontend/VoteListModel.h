//
//  VoteListModel.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface VoteListModel : JSONModel

@property (strong, nonatomic) NSString *m_sUserName;
@property (strong, nonatomic) NSString *m_sUserPic;
@property (strong, nonatomic) NSString *m_sRestaurantId;
@property (strong, nonatomic) NSString *m_sRestaurantName;
@property (strong, nonatomic) NSString *m_sState;
@property (strong, nonatomic) NSString *m_sId;

//not part of the json response.
@property (strong, nonatomic) NSNumber<Optional> *m_oDidVote;
@property (strong, nonatomic) NSNumber<Optional> *m_oVoteCount;
@property (strong, nonatomic) NSMutableDictionary<Optional> *m_oVoteIds;

@end

@protocol VoteListModel

@end