//
//  TimeHandler.m
//  Mealplan
//
//  Created by Mao on 10/29/15.
//  Copyright © 2015 Mao. All rights reserved.
//

#import "TimeHandler.h"

@implementation TimeHandler

+ (NSDate *)findDate:(NSString *)sTargetWeekDay {
    int iTargetWeekDay = [self convertDaytoNumber:sTargetWeekDay];
    NSDate *oReferenceDate = [NSDate date];
    NSCalendar *oCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *oDateComponents = [oCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday) fromDate:oReferenceDate];
    
    NSDate *oTargetDate;
    if (oDateComponents.weekday >= iTargetWeekDay)
    {
        oDateComponents.weekday = iTargetWeekDay;
        oTargetDate = [oCalendar dateFromComponents:oDateComponents];
        NSDateComponents *oTempDateComponents = [[NSDateComponents alloc] init];
        [oTempDateComponents setDay:7];
        oTargetDate = [oCalendar dateByAddingComponents:oTempDateComponents toDate:oTargetDate options:0];
    }
    else
    {
        oDateComponents.weekday = iTargetWeekDay;
        oTargetDate = [oCalendar dateFromComponents:oDateComponents];
    }
    
    return oTargetDate;
}

+ (int)convertDaytoNumber:(NSString *)sDay {
    if([[sDay uppercaseString] isEqualToString:@"MON"])
        return 2;
    else if([[sDay uppercaseString] isEqualToString:@"TUE"])
        return 3;
    else if([[sDay uppercaseString] isEqualToString:@"WED"])
        return 4;
    else if([[sDay uppercaseString] isEqualToString:@"THU"])
        return 5;
    else if([[sDay uppercaseString] isEqualToString:@"FRI"])
        return 6;
    else if([[sDay uppercaseString] isEqualToString:@"SAT"])
        return 7;
    else
        return 1;
}

+ (NSString *)convertNumberToDay:(int)iDay {
    if(iDay == 0)
        return @"MON";
    else if(iDay == 1)
        return @"TUE";
    else if(iDay == 2)
        return @"WED";
    else if(iDay == 3)
        return @"THU";
    else if(iDay == 4)
        return @"FRI";
    else if(iDay == 5)
        return @"SAT";
    else
        return @"SUN";
}

+ (NSString *)convertDayString:(NSString *)sDay {
    if([[sDay uppercaseString] isEqualToString:@"MON"])
        return @"Monday";
    else if([[sDay uppercaseString] isEqualToString:@"TUE"])
        return @"Tuesday";
    else if([[sDay uppercaseString] isEqualToString:@"WED"])
        return @"Wednesday";
    else if([[sDay uppercaseString] isEqualToString:@"THU"])
        return @"Thursday";
    else if([[sDay uppercaseString] isEqualToString:@"FRI"])
        return @"Friday";
    else if([[sDay uppercaseString] isEqualToString:@"SAT"])
        return @"Saturday";
    else
        return @"Sunday";
}

@end
