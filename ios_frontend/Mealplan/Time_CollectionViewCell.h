 //
//  Time_CollectionViewCell.h
//  Mealplan
//
//  Created by Mao on 7/14/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeListModel.h"
#import "TimeHandler.h"

@interface Time_CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) TimeListModel *m_oTimeListModel;
@property (weak, nonatomic) IBOutlet UILabel *m_oDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oTimeLabel;

- (void)setLabels;
- (NSString *)getDayText;
- (NSString *)getTimeText;
- (NSString *)getDateText;

@end
