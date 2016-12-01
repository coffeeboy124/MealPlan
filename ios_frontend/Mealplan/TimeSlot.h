//
//  TimeSlot.h
//  Mealplan
//
//  Created by Mao on 7/10/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeSlotDelegate;

@interface TimeSlot : UIView

@property (strong, nonatomic) UIButton *m_oUpButton;
@property (strong, nonatomic) UIButton *m_oDownButton;
@property (assign, nonatomic) int m_iStartMinute;
@property (assign, nonatomic) int m_iEndMinute;
@property (weak, nonatomic) id<TimeSlotDelegate> m_oDelegate;

- (void)changeTimeSlot:(CGRect)oFrame;
- (void)showButtons;
- (void)hideButtons;
- (void)createButtons;

@end

@protocol TimeSlotDelegate <NSObject>

- (void)clickSlot:(TimeSlot *)oTimeSlot;
- (void)upWasDragged:(CGPoint)oLocation;
- (void)downWasDragged:(CGPoint)oLocation;

@end
