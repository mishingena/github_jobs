//
//  JobsListViewModel.h
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JobItem, NetworkService, CacheService;

@interface JobsListViewModel : NSObject

@property (nonatomic) BOOL loading;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSArray<JobItem *> *items;
@property (nonatomic, strong) NSArray<JobItem *> *cachedItems;
@property (nonatomic, strong) NetworkService *networkService;
@property (nonatomic, strong) CacheService *cacheService;

@property (nonatomic, readonly) NSArray<JobItem *> *displayItems;

- (void)requestLoadItemsFromStartWithCompletion:(void(^)(void))completion;
- (void)cancelLoading;

@end
