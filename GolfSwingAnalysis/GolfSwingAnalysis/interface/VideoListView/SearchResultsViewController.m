//
//  SearchResultsViewController.m
//  GolfSwingAnalysis
//
//  Created by AnCheng on 1/4/16.
//  Copyright © 2016 Zhemin Yin. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "VideoTableCell.h"

@interface SearchResultsViewController ()

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *VideoCellIndentifier = @"VideoCellIndentifier";
    VideoTableCell *videoCell = (VideoTableCell *)[tableView dequeueReusableCellWithIdentifier:VideoCellIndentifier forIndexPath:indexPath];
    videoCell.index = (int)indexPath.row;
    VideoEntity *entity = [self.searchResults objectAtIndex:indexPath.row];
    [videoCell setEntity:entity];
    return videoCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // extract array from observer
    self.searchResults = [(NSArray *)object valueForKey:@"results"];
    [self.tableView reloadData];
}

@end
