//
//  TimeListModel.h
//  Mealplan
//
//  Created by Mao on 7/11/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface TimeListModel : JSONModel

@property (strong, nonatomic) NSString *m_sStartTime;
@property (strong, nonatomic) NSString *m_sEndTime;
@property (strong, nonatomic) NSString *m_sDay;

@end

@protocol TimeListModel

@end