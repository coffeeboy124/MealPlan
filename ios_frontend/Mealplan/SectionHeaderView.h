//
//  SectionHeaderView.h
//  Mao_Tutorial_2
//
//  Created by Mao on 6/29/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SectionHeaderViewDelegate;

@interface SectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *m_oExpandButton;
@property (weak, nonatomic) IBOutlet UILabel *m_oNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *m_oIconImage;
@property (weak, nonatomic) id <SectionHeaderViewDelegate> m_oDelegate;
@property (assign, nonatomic) NSInteger m_iSection;

- (void)toggleOpenWithUserAction:(BOOL)userAction;

@end

@protocol SectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

@end
