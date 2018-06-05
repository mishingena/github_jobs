//
//  JobDetailsViewController.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "JobDetailsViewController.h"
#import "JobViewModel.h"
#import "JobItem.h"


@interface JobDetailsViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *footerActivityIndicator;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) JobViewModel *viewModel;
@end


@implementation JobDetailsViewController

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


- (JobViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [JobViewModel new];
        _viewModel.jobId = self.jobId;
    }
    return _viewModel;
}

// MARK: Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor clearColor];
    
    if (self.jobId != nil) {
        __weak typeof(self) wSelf = self;
        [self.viewModel requestLoadItemWithCompletion:^{
            typeof(self) self = wSelf;
            [self updateUIAnimated:YES];
        }];
    }
    [self updateUIAnimated:NO];
}

- (void)updateUIAnimated:(BOOL)animated {
    CGPoint contentOffset = self.tableView.contentOffset;
    [self.tableView reloadData];
    self.tableView.contentOffset = contentOffset;
    
    if (self.viewModel.loading) {
        self.tableView.tableFooterView = self.footerActivityIndicator;
    } else if (self.viewModel.error != nil) {
        self.footerLabel.text = self.viewModel.error.localizedDescription;
        self.tableView.tableFooterView = self.footerLabel;
    } else {
        self.tableView.tableFooterView = [UIView new];
    }
    
    self.navigationItem.title = self.viewModel.displayItem.title;
}

// MARK: - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.viewModel.displayItem != nil) {
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JobItem *job = self.viewModel.displayItem;
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.text = job.createDateString;
        cell.textLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = job.company;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.text = job.title;
        cell.textLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = job.location;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else if (indexPath.row == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = job.jobDescription;
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

@end
