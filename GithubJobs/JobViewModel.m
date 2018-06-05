//
//  JobViewModel.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "JobViewModel.h"
#import "NetworkService.h"
#import "JobItem.h"
#import "CacheService.h"


@interface JobViewModel ()
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@end


@implementation JobViewModel

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
        NSString *filename = [NSString stringWithFormat:@"job_%@.dat", self.jobId];
        _cacheService.filePath = [[CacheService documentsPath] stringByAppendingPathComponent:filename];
    }
    return _cacheService;
}

- (JobItem *)displayItem {
    if (self.item != nil) return self.item;
    return self.cachedItem;
}

// MARK: - Loading

- (void)requestLoadItemFromCacheWithCompletion:(void (^)(void))completion {
    __weak typeof(self) wSelf = self;
    // first load
    [self.cacheService fetchContentsWithCompletion:^(JobItem *contents) {
        typeof(self) self = wSelf;
        self.cachedItem = contents;
        if (completion) completion();
    }];
}

- (void)requestLoadItemWithCompletion:(void (^)(void))completion {
    if (self.item == nil) {
        [self requestLoadItemFromCacheWithCompletion:completion];
    }
    
    NSCParameterAssert(self.jobId.length > 0);
    NSString *urlString = [NSString stringWithFormat:@"https://jobs.github.com/positions/%@.json?markdown=true", self.jobId];
    NSURL *url = [NSURL URLWithString:urlString];
    self.loading = YES;
    __weak typeof(self) wSelf = self;
    self.dataTask = [[NetworkService sharedInstance] GET:url completion:^(id json, NSError *error) {
        typeof(self) self = wSelf;

        self.loading = NO;
        self.error = error;

        if (error != nil) {
            if (completion) completion();
            return;
        }

        JobItem *item = [JobItem importFromDetailItemJSON:json];
        self.item = item;
        self.dataTask = nil;
        
        // update cache
        [self.cacheService updateContents:self.item completion:nil];

        if (completion) completion();
    }];
}

- (void)cancelLoading {
    if (self.dataTask != nil) {
        [self.dataTask cancel];
    }
}

@end
