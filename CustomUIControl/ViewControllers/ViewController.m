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
static NSTimeInterval const kAnimationDuration = 0.3;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (weak, nonatomic) IBOutlet UIToolbar *editToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchDataWithCompletion:^(NSMutableArray *data) {
        self.data = data;
        [self.tableView reloadData];
    }];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0f;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self setupRefreshControlForTableView:self.tableView];
    
    [self dismissToolbar:NO];
}

#pragma mark - Data
- (void)fetchDataWithCompletion:(void(^)(NSMutableArray *data))completion {
    
    NSParameterAssert(completion);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *data = [NSMutableArray array];
        for (int loop = 0; loop < 20; loop++) {
            NSDictionary *dataDictionary = @{@"number":@(loop), @"title":@"Moderato", @"body":@"Music In moderate tempo that is slower than allegretto but faster than andante. Used chiefly as a direction.", @"subtitle":@"from The American Heritage® Dictionary of the English Language, 4th Edition", @"flagged":@(NO)};
            [data addObject:dataDictionary];
        }
        completion(data);
    });
}

#pragma mark - Refresh Control Action
- (void)setupRefreshControlForTableView:(UITableView *)tableView {
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    self.refreshControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:self.refreshControl];
}

- (void)refreshData {
    [self fetchDataWithCompletion:^(NSMutableArray *data) {
        self.data = data;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
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
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView beginUpdates];
        [self.data removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }];
    
    UITableViewRowAction *archiveRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Flag" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSMutableDictionary *dataDictionary = [self.data[indexPath.row] mutableCopy];
        dataDictionary[@"flagged"] = @(YES);
        self.data[indexPath.row] = dataDictionary;
        [tableView setEditing:NO animated:YES];
        // TODO
        // add dataDictionary to Archive.
        // Remove cell from tableView
    }];
    archiveRowAction.backgroundColor = [UIColor greenColor];
    
    return @[deleteRowAction, archiveRowAction];
}

// Move
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    if ([sourceIndexPath isEqual:destinationIndexPath]) { return; }
    
    NSDictionary *movedDataDictionary = self.data[sourceIndexPath.row];
    [self.data removeObjectAtIndex:sourceIndexPath.row];
    [self.data insertObject:movedDataDictionary atIndex:destinationIndexPath.row];
}

#pragma mark - UIBarButton Actions
- (IBAction)barButtonTapped:(UIBarButtonItem *)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    [self updatedEditingUI];
}

- (void)updatedEditingUI {
    if ([self.tableView isEditing]) {
        [self.refreshControl removeFromSuperview];
        [self.editBarButton setTitle:@"Done"];
        [self presentToolbar];
    } else {
        [self.refreshControl endRefreshing];
        [self.tableView addSubview:self.refreshControl];
        [self.editBarButton setTitle:@"Edit"];
        [self dismissToolbar:YES];
    }
}

#pragma mark - EditToolbar
- (void)presentToolbar {
    self.toolbarBottomConstraint.constant = 0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)dismissToolbar:(BOOL)animated {
    self.toolbarBottomConstraint.constant = -CGRectGetHeight(self.editToolbar.bounds);
    NSTimeInterval animationTime = animated ? kAnimationDuration : 0.0;
    [UIView animateWithDuration:animationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - EditToolbar Actions
- (IBAction)deleteSelectedTapped:(id)sender {
   
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    if ([selectedIndexPaths count] == 0) {
        return;
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *selectedIndexPath in selectedIndexPaths) {
        [indexSet addIndex:selectedIndexPath.row];
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        // required to reload visible cells as the heights of the cells aren't autmatically resized after delete.
        [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [self.tableView beginUpdates];
    [self.data removeObjectsAtIndexes:indexSet];
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [CATransaction commit];

    [self.tableView setEditing:NO animated:YES];
    [self updatedEditingUI];
}

- (IBAction)selectAllTapped:(id)sender {
    for (int loop = 0; loop < [self tableView:self.tableView numberOfRowsInSection:0]; loop++) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:loop inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end
