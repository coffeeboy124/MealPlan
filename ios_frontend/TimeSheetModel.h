//
//  TimeSheetModel.h
//  Mealplan
//
//  Created by Mao on 7/24/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface TimeSheetModel : JSONModel

@property (strong, nonatomic) NSString *m_sId;
@property (strong, nonatomic) NSString *m_sName;
@property (strong, nonatomic) NSString *m_sState;

@end

@protocol TimeSheetModel

@end
