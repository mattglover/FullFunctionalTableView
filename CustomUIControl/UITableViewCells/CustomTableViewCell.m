//
//  CustomTableViewCell.m
//  CustomUIControl
//
//  Created by Matt Glover on 05/10/2015.
//  Copyright © 2015 Duchy Software Ltd. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "CustomView.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeDynamicTypeSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureView {
    self.customTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.customTitleLabel.numberOfLines = 0;
    [self.customTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)didChangeDynamicTypeSize:(NSNotification *)notification {
    [self configureView];
}

@end
