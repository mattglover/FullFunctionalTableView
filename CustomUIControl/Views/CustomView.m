//
//  CustomView.m
//  CustomUIControl
//
//  Created by Matt Glover on 05/10/2015.
//  Copyright © 2015 Duchy Software Ltd. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];

    [self setupSubviews];
    [self configureSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeDynamicTypeSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup UI
- (void)setupSubviews {
    _bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.textColor = [UIColor darkTextColor];
    [self addSubview:self.bodyLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.textColor = [UIColor grayColor];
    [self addSubview:self.subtitleLabel];
}

#pragma mark - Configure UI
- (void)configureSubviews {
    self.bodyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

#pragma mark - Constraints
- (void)updateConstraints {
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_bodyLabel, _subtitleLabel);
    [self removeConstraints:self.constraints];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bodyLabel]-(>=0)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_subtitleLabel]-(>=0)-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_bodyLabel]-8-[_subtitleLabel]|" options:0 metrics:nil views:views]];
    
    [super updateConstraints];
}

#pragma mark - Notification Listeners
- (void)didChangeDynamicTypeSize:(NSNotification *)notification {
    [self configureSubviews];
}

@end
