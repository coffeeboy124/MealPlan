//
//  TimeHandler.h
//  Mealplan
//
//  Created by Mao on 10/29/15.
//  Copyright © 2015 Mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeHandler : NSObject

+ (NSDate *)findDate:(NSString *)sTargetWeekDay;
+ (int)convertDaytoNumber:(NSString *)sDay;
+ (NSString *)convertNumberToDay:(int)iDay;
+ (NSString *)convertDayString:(NSString *)sDay;

@end
