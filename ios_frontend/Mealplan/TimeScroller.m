//
//  TimeEditor.m
//  Mealplan
//
//  Created by Mao on 7/9/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "TimeScroller.h"

@implementation TimeScroller

@synthesize m_fIndicatorHeight;
@synthesize m_iSelectedIndex;
@synthesize m_oIndicatorView;
@synthesize m_oButtons;
@synthesize m_oViews;
@synthesize m_bAnimationInProgress;
@synthesize m_oSelectedColor;
@synthesize m_oUnselectedColor;
@synthesize m_bDisabled;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseClassInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        [self baseClassInit];
    }
    return self;
}

- (void)baseClassInit {
    m_bDisabled = NO;
    m_iSelectedIndex = 0;
    m_oButtons = [[NSMutableArray alloc] init];
    m_oViews = [[NSMutableArray alloc] init];
    m_bAnimationInProgress = NO;
    m_fIndicatorHeight = 3;
    m_oIndicatorView = [[UIView alloc] init];
    
    m_oSelectedColor = [UIColor blueColor];
    m_oUnselectedColor = [UIColor blackColor];
    m_oIndicatorView.backgroundColor = [UIColor blueColor];
    
    NSArray *oDaysOfWeek = @[@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun"];
    for(int i=0; i<oDaysOfWeek.count; i++)
    {
        UIButton *oButton = [[UIButton alloc] init];
        [oButton setTitle:oDaysOfWeek[i] forState:UIControlStateNormal];
        [oButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.m_oButtons addObject:oButton];
    }
    
    [self addButtons];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self redrawComponents];
}

- (void) addButtons{
    for(int i=0; i<m_oButtons.count; i++){
        UIButton *oButton = m_oButtons[i];
        oButton.tag = i;
        [oButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:oButton];
        [self addSubview:m_oIndicatorView];
    }
}

- (void)buttonSelected:(UIButton *)oSender{
    if(m_bDisabled)
        return;
    if (oSender.tag == m_iSelectedIndex)
        return;
    [self moveToIndex:(int)oSender.tag isAnimated:YES moveScroll:YES];
}

- (void)redrawComponents{
    [self redrawButtons];
    
    if (m_oButtons.count > 0)
        [self moveToIndex:(int)m_iSelectedIndex isAnimated:NO moveScroll:NO];
}

- (void)moveToIndex:(int)iIndex isAnimated:(BOOL)bIsAnimated moveScroll:(BOOL)bMoveScroll{
    m_iSelectedIndex = iIndex;
    m_bAnimationInProgress = YES;
    
    [UIView animateWithDuration:bIsAnimated?0.2:0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat fWidth = self.frame.size.width / m_oButtons.count;
        UIButton *oButton = m_oButtons[iIndex];
        [self redrawButtons];
        m_oIndicatorView.frame = CGRectMake(fWidth * iIndex, self.frame.size.height - self.m_fIndicatorHeight, oButton.frame.size.width, self.m_fIndicatorHeight);
    
    } completion:^(BOOL finished) {
        if(self != nil)
        {
            self.m_bAnimationInProgress = NO;
            [self.m_oDelegate changedToDay:iIndex];
        }
        return;
    }];
}

- (void)redrawButtons{
    if(self.m_oButtons.count == 0)
        return;
    
    CGFloat fWidth = self.frame.size.width / m_oButtons.count;
    CGFloat fHeight = self.frame.size.height - m_fIndicatorHeight;
    
    for (int i=0; i<m_oButtons.count; i++) {
        UIButton *oButton = m_oButtons[i];
        oButton.frame = CGRectMake(fWidth * i, 0, fWidth, fHeight);
        if(i == m_iSelectedIndex)
        {
            [oButton setTitleColor:m_oSelectedColor forState:UIControlStateNormal];
        }
        else
        {
            [oButton setTitleColor:m_oUnselectedColor forState:UIControlStateNormal];
        }
    }
}

@end
