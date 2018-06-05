//
//  JobsListViewModel.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "JobsListViewModel.h"
#import "NetworkService.h"
#import "JobItem.h"
#import "CacheService.h"

@interface JobsListViewModel ()
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@end

@implementation JobsListViewModel

// MARK: - Lazy load

- (NetworkService *)networkService {
    if (!_networkService) {
        _networkService = [NetworkService sharedInstance];
    }
    return _networkService;
}

- (CacheService *)cacheService {
    if (!_cacheService) {
        _cacheService = [CacheService new];
        _cacheService.filePath = [[CacheService documentsPath] stringByAppendingPathComponent:@"jobs_list.db"];
    }
    return _cacheService;
}

- (NSArray<JobItem *> *)displayItems {
    if (self.items.count > 0) return self.items;
    return self.cachedItems;
}

// MARK: - Loading

- (void)requestLoadItemsFromCacheWithCompletion:(void (^)(void))completion {
    __weak typeof(self) wSelf = self;
    [self.cacheService fetchContentsWithCompletion:^(NSArray *items) {
        typeof(self) self = wSelf;
        self.cachedItems = items;
        if (completion) completion();
    }];
}

- (void)requestLoadItemsFromStartWithCompletion:(void (^)(void))completion {
    if (self.items.count < 1) {
        [self requestLoadItemsFromCacheWithCompletion:completion];
    }
    
    NSURL *url = [NSURL URLWithString:@"https://jobs.github.com/positions.json?description=ios"];
    self.loading = YES;
    __weak typeof(self) wSelf = self;
    self.dataTask = [self.networkService GET:url completion:^(id json, NSError *error) {
        typeof(self) self = wSelf;
        self.loading = NO;
        self.error = error;
        
        if (error != nil) {
            if (completion) completion();
            return;
        }
        
        NSArray *jsonItems = (NSArray *)json;
        NSMutableArray *items = [NSMutableArray new];
        for (NSDictionary *item in jsonItems) {
            JobItem *obj = [JobItem importFromListItemJSON:item];
            [items addObject:obj];
        }
        self.items = items;
        self.dataTask = nil;
        
        [self.cacheService updateContents:self.items completion:nil];
        
        if (completion) completion();
    }];
}

- (void)cancelLoading {
    if (self.dataTask != nil) {
        [self.dataTask cancel];
    }
}

@end
