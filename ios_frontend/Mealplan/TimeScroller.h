//
//  TimeEditor.h
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeScrollerDelegate;

@interface TimeScroller : UIView

@property (assign, nonatomic) CGFloat m_fIndicatorHeight;
@property (assign, nonatomic) NSInteger m_iSelectedIndex;
@property (strong, nonatomic) UIView *m_oIndicatorView;
@property (strong, nonatomic) NSMutableArray *m_oButtons;
@property (strong, nonatomic) NSMutableArray *m_oViews;
@property (assign, nonatomic) BOOL m_bAnimationInProgress;
@property (strong, nonatomic) UIColor *m_oSelectedColor;
@property (strong, nonatomic) UIColor *m_oUnselectedColor;
@property (assign, nonatomic) BOOL m_bDisabled;
@property (weak, nonatomic) id<TimeScrollerDelegate> m_oDelegate;

@end

@protocol TimeScrollerDelegate <NSObject>

- (void)changedToDay:(int)iDay;

@end
