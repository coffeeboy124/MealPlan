//
//  ServerResponseModel.h
//  Mealplan
//
//  Created by Mao on 7/3/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "JSONModel.h"

@interface ServerResponseModel : JSONModel

@property (strong, nonatomic) NSString *m_sResult;
@property (strong, nonatomic) NSString *m_sError;
@property (strong, nonatomic) NSString *m_sOutput;

@end