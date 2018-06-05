//
//  JobsListViewController.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "JobsListViewController.h"
#import "JobsListViewModel.h"
#import "JobItem.h"
#import "JobDetailsViewController.h"
#import <SafariServices/SafariServices.h>


@interface JobsListViewController ()
@property (nonatomic, strong) JobsListViewModel *viewModel;
@property (nonatomic, strong) UIActivityIndicatorView *footerActivityIndicator;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIRefreshControl *pullToReresh;
@end


@implementation JobsListViewController

// MARK: Lazy load

- (JobsListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [JobsListViewModel new];
    }
    return _viewModel;
}

- (UIActivityIndicatorView *)footerActivityIndicator {
    if (!_footerActivityIndicator) {
        _footerActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _footerActivityIndicator.frame = CGRectMake(0, 0, 44., 44.);
        [_footerActivityIndicator startAnimating];
    }
    return _footerActivityIndicator;
}

- (UILabel *)footerLabel {
    if (!_footerLabel) {
        _footerLabel = [UILabel new];
        _footerLabel.frame = CGRectMake(0, 0, 200, 44);
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.font = [UIFont systemFontOfSize:14];
        _footerLabel.textColor = [UIColor grayColor];
        _footerLabel.numberOfLines = 0;
    }
    return _footerLabel;
}

// MARK: - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"GitHub Jobs", @"");
    
    UIRefreshControl *pullToReresh = [[UIRefreshControl alloc] init];
    [pullToReresh addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    _pullToReresh = pullToReresh;
    [self.tableView addSubview:pullToReresh];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(featureAction:)];
    
    __weak typeof(self) wSelf = self;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        typeof(self) self = wSelf;
        [self updateUIAnimated:YES];
    }];
    [self updateUIAnimated:NO];
}

- (void)updateUIAnimated:(BOOL)animated {
    CGPoint contentOffset = self.tableView.contentOffset;
    [self.tableView reloadData];
    self.tableView.contentOffset = contentOffset;
    
    if (self.viewModel.loading) {
        if (self.pullToReresh.isRefreshing) {
            self.tableView.tableFooterView = [UIView new];
        } else {
            self.tableView.tableFooterView = self.footerActivityIndicator;
        }
    } else if (self.viewModel.error != nil) {
        self.footerLabel.text = self.viewModel.error.localizedDescription;
        self.tableView.tableFooterView = self.footerLabel;
    } else {
        self.tableView.tableFooterView = [UIView new];
    }
    
    if (!self.viewModel.loading) {
        if (self.pullToReresh.isRefreshing) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pullToReresh endRefreshing];
            });
        }
    }
}

// MARK: - Actions

- (void)refreshAction:(UIRefreshControl *)sender {
    if (self.viewModel.loading) {
        [self.viewModel cancelLoading];
    }
    __weak typeof(self) wSelf = self;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        typeof(self) self = wSelf;
        [self updateUIAnimated:YES];
    }];
}

- (void)featureAction:(UIBarButtonItem *)sender {
    NSURL *url = [NSURL URLWithString:@"https://drive.google.com/file/d/1F6vH6Ld-FKUSGPEKVSksJKI6GiKLSWx0/view"];
    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:vc animated:YES completion:nil];
}

// MARK: - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.displayItems.count;
}

static NSString *const kCellId = @"CellId";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    }
    
    JobItem *item = [self.viewModel.displayItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.company;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JobItem *item = [self.viewModel.displayItems objectAtIndex:indexPath.row];

    JobDetailsViewController *vc = [JobDetailsViewController new];
    vc.jobId = item.uid;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
