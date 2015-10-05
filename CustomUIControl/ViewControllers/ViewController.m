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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;
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
    if ([self.tableView isEditing]) {
        [sender setTitle:@"Done"];
    } else {
        [sender setTitle:@"Edit"];
    }
}

@end
