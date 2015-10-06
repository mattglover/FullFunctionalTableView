//
//  ViewController.m
//  CustomUIControl
//
//  Created by Matt Glover on 05/10/2015.
//  Copyright © 2015 Duchy Software Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "CustomView.h"

static NSString * const kCustomTableViewCellIdentifier = @"CustomTableViewCell";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (weak, nonatomic) IBOutlet UIToolbar *editToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSMutableArray *data = [NSMutableArray array];
    for (int loop = 0; loop < 20; loop++) {
        NSDictionary *dataDictionary = @{@"number":@(loop), @"title":@"Moderato", @"body":@"Music In moderate tempo that is slower than allegretto but faster than andante. Used chiefly as a direction.", @"subtitle":@"from The American Heritage® Dictionary of the English Language, 4th Edition"};
        [data addObject:dataDictionary];
    }
    self.data = data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0f;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self dismissToolbar:NO];
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dataDictionary = self.data[indexPath.row];
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomTableViewCellIdentifier forIndexPath:indexPath];
    cell.customTitleLabel.text = [NSString stringWithFormat:@"(%@) %@", dataDictionary[@"number"], dataDictionary[@"title"]];
    cell.customView.bodyLabel.text = dataDictionary[@"body"];
    cell.customView.subtitleLabel.text = dataDictionary[@"subtitle"];
    
    return cell;
}

#pragma mark - UITableView Delegate
// Move
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSDictionary *movedDataDictionary = self.data[sourceIndexPath.row];
    [self.data removeObjectAtIndex:sourceIndexPath.row];
    [self.data insertObject:movedDataDictionary atIndex:destinationIndexPath.row];
}

// Delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [tableView endUpdates];
}

#pragma mark - UIBarButton Actions
- (IBAction)barButtonTapped:(UIBarButtonItem *)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    [self toggleEditingUI];
}

- (void)toggleEditingUI {
    if ([self.tableView isEditing]) {
        [self.editBarButton setTitle:@"Done"];
        [self presentToolbar];
    } else {
        [self.editBarButton setTitle:@"Edit"];
        [self dismissToolbar:YES];
    }
}

#pragma mark - EditToolbar
- (void)presentToolbar { // always animated
    self.toolbarBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)dismissToolbar:(BOOL)animated {
    self.toolbarBottomConstraint.constant = -CGRectGetHeight(self.editToolbar.bounds);
    NSTimeInterval animationTime = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:animationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - EditToolbar Actions
- (IBAction)deleteSelectedTapped:(id)sender {
   
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *selectedIndexPath in selectedIndexPaths) {
        [indexSet addIndex:selectedIndexPath.row];
    }
    
    [self.tableView beginUpdates];
    [self.data removeObjectsAtIndexes:indexSet];
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self.tableView setEditing:NO animated:YES];
    [self toggleEditingUI];
}

- (IBAction)selectAllTapped:(id)sender {
    for (int loop = 0; loop < [self tableView:self.tableView numberOfRowsInSection:0]; loop++) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:loop inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end
