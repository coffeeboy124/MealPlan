//
//  Select_TableViewCell.m
//  Mealplan
//
//  Created by Mao on 7/8/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "Select_TableViewCell.h"

@implementation Select_TableViewCell

@synthesize m_oCheckButton;

- (void)awakeFromNib {
    [m_oCheckButton setImage:[UIImage imageNamed:@"checkbox2_selected.png"] forState:UIControlStateSelected];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(toggleOpen:)];
    [m_oCheckButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addGestureRecognizer:tapGesture];
}

- (IBAction)toggleOpen:(id)sender {
    [UIView transitionWithView:m_oCheckButton
                      duration:.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        m_oCheckButton.selected = !m_oCheckButton.selected;;
                    } completion:nil];
}

@end
