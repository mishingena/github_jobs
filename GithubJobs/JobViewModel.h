//
//  JobViewModel.h
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JobItem, NetworkService, CacheService;

@interface JobViewModel : NSObject

@property (nonatomic, strong) NSString *jobId;
@property (nonatomic) BOOL loading;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) JobItem *item;
@property (nonatomic, strong) JobItem *cachedItem;
@property (nonatomic, strong) NetworkService *networkService;
@property (nonatomic, strong) CacheService *cacheService;

@property (nonatomic, readonly) JobItem *displayItem;

- (void)requestLoadItemWithCompletion:(void(^)(void))completion;
- (void)cancelLoading;

@end
