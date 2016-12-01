//
//  Time_CollectionViewCell.m
//  Mealplan
//
//  Created by Mao on 7/14/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "Time_CollectionViewCell.h"

@implementation Time_CollectionViewCell

@synthesize m_oTimeListModel;
@synthesize m_oDateLabel;
@synthesize m_oDayLabel;
@synthesize m_oTimeLabel;

- (void)setLabels{
    m_oDayLabel.text  = [TimeHandler convertDayString:m_oTimeListModel.m_sDay];
    m_oTimeLabel.text = [NSString stringWithFormat:@"%@ - %@", [self convertTimeString:m_oTimeListModel.m_sStartTime], [self convertTimeString:m_oTimeListModel.m_sEndTime]];
    m_oDateLabel.text = [self findDate:m_oTimeListModel.m_sDay];
}

- (NSString *)getDayText{
    return [TimeHandler convertDayString:m_oTimeListModel.m_sDay];
}

- (NSString *)getTimeText{
    return [self convertTimeString:m_oTimeListModel.m_sStartTime];
}

- (NSString *)getDateText{
    return [self findDate:m_oTimeListModel.m_sDay];
}

- (NSString *)convertTimeString:(NSString *)sTime {
    NSArray *oTimes = [sTime componentsSeparatedByString:@":"];
    if([oTimes[0] intValue] == 0)
        return [NSString stringWithFormat:@"%02d:%02d %@", 12, [oTimes[1] intValue], @"AM"];
    if([oTimes[0] intValue] > 12)
        return [NSString stringWithFormat:@"%02d:%02d %@", [oTimes[0] intValue] - 12, [oTimes[1] intValue], @"PM"];
    return [NSString stringWithFormat:@"%02d:%02d %@", [oTimes[0] intValue], [oTimes[1] intValue], @"AM"];
}

- (NSString *)findDate:(NSString *)sDay {
    NSDate *oTargetDate = [TimeHandler findDate:sDay];
    NSDateFormatter *oDateFormatter = [[NSDateFormatter alloc] init];
    [oDateFormatter setDateFormat:@"MMM dd"];
    return [oDateFormatter stringFromDate:oTargetDate];
}

@end
