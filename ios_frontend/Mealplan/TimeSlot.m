//
//  TimeSlot.m
//  Mealplan
//
//  Created by Mao on 7/10/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "TimeSlot.h"

#define DRAG_BUTTON_LENGTH 100
#define DRAG_BUTTON_HEIGHT 10

@implementation TimeSlot
@synthesize m_oDelegate;
@synthesize m_oUpButton;
@synthesize m_oDownButton;

- (id)initWithFrame:(CGRect)oFrame{
    if ((self = [super initWithFrame:oFrame])) {
        [self baseClassInit];
        [self createButtons];
    }
    return self;
}

- (void)baseClassInit {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(clickSlot:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)createButtons {
    CGRect oFrame = self.frame;
    
    m_oUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_oUpButton.frame = CGRectMake((oFrame.size.width - DRAG_BUTTON_LENGTH) / 2, 0, DRAG_BUTTON_LENGTH, DRAG_BUTTON_HEIGHT);
    [m_oUpButton setBackgroundColor:[UIColor colorWithRed:162.0/255.0 green:222.0/255.0 blue:208.0/255.0 alpha:0.7f]];
    [m_oUpButton addTarget:self action:@selector(upWasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [m_oUpButton addTarget:self action:@selector(upWasDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    
    m_oDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_oDownButton.frame = CGRectMake((oFrame.size.width - DRAG_BUTTON_LENGTH) / 2, oFrame.size.height - DRAG_BUTTON_HEIGHT, DRAG_BUTTON_LENGTH, DRAG_BUTTON_HEIGHT);
    [m_oDownButton setBackgroundColor:[UIColor colorWithRed:162.0/255.0 green:222.0/255.0 blue:208.0/255.0 alpha:0.7f]];
    [m_oDownButton addTarget:self action:@selector(downWasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [m_oDownButton addTarget:self action:@selector(downWasDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
}

- (void)changeTimeSlot:(CGRect)oFrame {
    [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        m_oUpButton.frame = CGRectMake((oFrame.size.width - DRAG_BUTTON_LENGTH) / 2, 0, DRAG_BUTTON_LENGTH, DRAG_BUTTON_HEIGHT);
        m_oDownButton.frame = CGRectMake((oFrame.size.width - DRAG_BUTTON_LENGTH) / 2, oFrame.size.height - DRAG_BUTTON_HEIGHT, DRAG_BUTTON_LENGTH, DRAG_BUTTON_HEIGHT);
        self.frame = oFrame;
        
    } completion:^(BOOL finished) {
        return;
    }];
}

- (void)clickSlot:(id)sender {
    [m_oDelegate clickSlot:self];
}

- (void)upWasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    UITouch *oTouch = [[event touchesForView:button] anyObject];
    [m_oDelegate upWasDragged:[oTouch locationInView:button]];
}

- (void)downWasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    UITouch *oTouch = [[event touchesForView:button] anyObject];
    [m_oDelegate downWasDragged:[oTouch locationInView:button]];
}

- (void)showButtons {
    [self addSubview:m_oUpButton];
    [self addSubview:m_oDownButton];
}

- (void)hideButtons {
    [m_oUpButton removeFromSuperview];
    [m_oDownButton removeFromSuperview];
}

@end
