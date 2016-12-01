//
//  SectionHeaderView.m
//  Mao_Tutorial_2
//
//  Created by Mao on 6/29/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "SectionHeaderView.h"

@implementation SectionHeaderView

@synthesize m_oExpandButton;
@synthesize m_oDelegate;

- (void)awakeFromNib {
    // set the selected image for the disclosure button
    [m_oExpandButton setImage:[UIImage imageNamed:@"downarrow.png"] forState:UIControlStateSelected];
    
    // set up the tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(toggleOpen:)];
    [m_oExpandButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addGestureRecognizer:tapGesture];
    [self toggleOpen:self];
}

- (IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}

- (void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // toggle the disclosure button state
    m_oExpandButton.selected = !m_oExpandButton.selected;
    
    // if this was a user action, send the delegate the appropriate message
    if (userAction) {
        if (m_oExpandButton.selected) {
            if ([m_oDelegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [m_oDelegate sectionHeaderView:self sectionOpened:self.m_iSection];
            }
        }
        else {
            if ([m_oDelegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [m_oDelegate sectionHeaderView:self sectionClosed:self.m_iSection];
            }
        }
    }
}


@end
