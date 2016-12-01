//
//  Vote_TableViewCell.h
//  Mealplan
//
//  Created by Mao on 7/15/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Vote_TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *m_oNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oSuggestedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_oVotesLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_oYelpButton;
@property (weak, nonatomic) IBOutlet UIButton *m_oVoteButton;

@end
