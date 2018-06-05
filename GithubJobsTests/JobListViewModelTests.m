//
//  JobListViewModelTests.m
//  GithubJobsTests
//
//  Created by Gena on 05.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JobsListViewModel.h"
#import "NetworkService.h"
#import "CacheService.h"
#import "JobItem.h"


@interface NetworkServiceMock : NetworkService
@property (nonatomic) id jsonMock;
@property (nonatomic, strong) NSError *errorMock;
@property (nonatomic) NSTimeInterval loadTime; // default to 1 sec.
@end

@implementation NetworkServiceMock
- (instancetype)init {
    self = [super init];
    if (self) {
        _loadTime = 1.0;
    }
    return self;
}
- (NSURLSessionDataTask *)GET:(NSURL *)url completion:(void (^)(id, NSError *))completion {
    // simulate loading with delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.loadTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion(self.jsonMock, self.errorMock);
    });
    return nil;
}
@end

@interface CacheServiceMock : CacheService
@property (nonatomic) id contentsMock;
@property (nonatomic) NSTimeInterval loadTime; // default to 0.5 sec.
@end

@implementation CacheServiceMock
- (instancetype)init {
    self = [super init];
    if (self) {
        _loadTime = 0.5;
    }
    return self;
}
- (void)fetchContentsWithCompletion:(void (^)(id))completion {
    // simulate loading with delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.loadTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion(self.contentsMock);
    });
}
- (void)updateContents:(id)contents completion:(void (^)(BOOL))completion {
    self.contentsMock = contents;
    if (completion) {
        completion(YES);
    }
}
@end



@interface JobListViewModelTests : XCTestCase
@property (nonatomic, strong) JobsListViewModel *viewModel;
@property (nonatomic, strong) NetworkServiceMock *networkService;
@property (nonatomic, strong) CacheServiceMock *cacheService;
@end

@implementation JobListViewModelTests

- (NSDictionary *)successJSON {
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"job_list" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    id json = nil;
    if (data != nil) {
        json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    return json;
}

- (NSArray<JobItem *> *)successItemsArray {
    NSArray *jsonItems = (NSArray *)[self successJSON];
    NSMutableArray *items = [NSMutableArray new];
    for (NSDictionary *item in jsonItems) {
        JobItem *obj = [JobItem importFromListItemJSON:item];
        [items addObject:obj];
    }
    return items;
}

- (NSArray<JobItem *> *)successCacheItemsArray {
    NSArray *items = [self successItemsArray];
    NSUInteger len = MAX(items.count, 2);
    return [items subarrayWithRange:NSMakeRange(0, len)];
}


- (void)setUp {
    [super setUp];
    self.networkService = [NetworkServiceMock new];
    self.cacheService = [CacheServiceMock new];
    self.viewModel = [JobsListViewModel new];
    self.viewModel.networkService = self.networkService;
    self.viewModel.cacheService = self.cacheService;
}

- (void)tearDown {
    self.viewModel = nil;
    self.networkService = nil;
    self.cacheService = nil;
    [super tearDown];
}

- (void)testSuccessLoadItemsWithInternetConnectionAndEmptyCache {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should succeed"];
  
    NSArray *expectedItems = [self successItemsArray];
    self.cacheService.contentsMock = nil;
    self.networkService.jsonMock = [self successJSON];
    self.networkService.errorMock = nil;
    
    __block NSInteger waitCallbacksCount = 2;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        waitCallbacksCount -= 1;
        if (waitCallbacksCount == 0) {
            [expectation fulfill];
        }
    }];
    XCTAssertTrue(self.viewModel.loading);
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertFalse(self.viewModel.loading);
    XCTAssertTrue([self.viewModel.items isEqualToArray:expectedItems]);
    XCTAssertTrue([self.viewModel.displayItems isEqualToArray:expectedItems]);
    XCTAssertNil(self.viewModel.error);
    XCTAssertNil(self.viewModel.cachedItems);
}

- (void)testSuccessLoadItemsWithInternetConnectionAndStoredCache {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should succeed"];
    
    NSArray *cacheItems = [self successCacheItemsArray];
    NSArray *expectedItems = [self successItemsArray];
    self.cacheService.contentsMock = cacheItems;
    self.networkService.jsonMock = [self successJSON];
    self.networkService.errorMock = nil;
    
    __block NSInteger waitCallbacksCount = 2;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        waitCallbacksCount -= 1;
        if (waitCallbacksCount == 0) {
            [expectation fulfill];
        }
    }];
    XCTAssertTrue(self.viewModel.loading);
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertFalse(self.viewModel.loading);
    XCTAssertTrue([self.viewModel.items isEqualToArray:expectedItems]);
    XCTAssertTrue([self.viewModel.displayItems isEqualToArray:expectedItems]);
    XCTAssertNil(self.viewModel.error);
    XCTAssertTrue([self.viewModel.cachedItems isEqualToArray:cacheItems]);
}

- (void)testLoadItemsWithoutInternetConnectionAndEmptyCache {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should succeed"];
    
    NSError *loadError = [NSError errorWithDomain:@"ErrorDomain" code:100 userInfo:nil];
    NSArray *cacheItems = [self successItemsArray];
    self.cacheService.contentsMock = cacheItems;
    self.networkService.jsonMock = nil;
    self.networkService.errorMock = loadError;
    
    __block NSInteger waitCallbacksCount = 2;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        waitCallbacksCount -= 1;
        if (waitCallbacksCount == 0) {
            [expectation fulfill];
        }
    }];
    XCTAssertTrue(self.viewModel.loading);
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertFalse(self.viewModel.loading);
    XCTAssertTrue(self.viewModel.items.count == 0);
    XCTAssertTrue([self.viewModel.displayItems isEqualToArray:cacheItems]);
    XCTAssertTrue([self.viewModel.error isEqual:loadError]);
    XCTAssertTrue([self.viewModel.cachedItems isEqualToArray:cacheItems]);
}

- (void)testLoadItemsWithoutInternetConnectionAndStoredCache {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should succeed"];
    
    NSError *loadError = [NSError errorWithDomain:@"ErrorDomain" code:100 userInfo:nil];
    self.cacheService.contentsMock = nil;
    self.networkService.jsonMock = nil;
    self.networkService.errorMock = loadError;
    
    __block NSInteger waitCallbacksCount = 2;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        waitCallbacksCount -= 1;
        if (waitCallbacksCount == 0) {
            [expectation fulfill];
        }
    }];
    XCTAssertTrue(self.viewModel.loading);
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertFalse(self.viewModel.loading);
    XCTAssertTrue(self.viewModel.items.count == 0);
    XCTAssertTrue(self.viewModel.displayItems.count == 0);
    XCTAssertTrue(self.viewModel.error == loadError);
    XCTAssertNil(self.viewModel.cachedItems);
}

- (void)testMultipleLoadItemsFromBeginingWithInternetConnection {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should succeed"];
    
    NSArray *expectedItems = [self successItemsArray];
    NSArray *cacheItems = [self successCacheItemsArray];
    NSArray *expectedCacheItems = expectedItems;
    self.cacheService.contentsMock = cacheItems;
    self.networkService.jsonMock = [self successJSON];
    self.networkService.errorMock = nil;
    
    __block NSInteger waitCallbacksCount = 2;
    __weak typeof(self) wSelf = self;
    [self.viewModel requestLoadItemsFromStartWithCompletion:^{
        typeof(self) self = wSelf;
        waitCallbacksCount -= 1;
        if (waitCallbacksCount == 0) {
            XCTAssertTrue([self.viewModel.cachedItems isEqualToArray:cacheItems]);
            
            __block NSInteger otherWaitCallbacksCount = 1;
            [self.viewModel requestLoadItemsFromStartWithCompletion:^{
                otherWaitCallbacksCount -= 1;
                if (otherWaitCallbacksCount == 0) {
                    [expectation fulfill];
                }
            }];
            
        }
    }];
    XCTAssertTrue(self.viewModel.loading);
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssertFalse(self.viewModel.loading);
    XCTAssertTrue([self.viewModel.items isEqualToArray:expectedItems]);
    XCTAssertTrue([self.viewModel.displayItems isEqualToArray:expectedItems]);
    XCTAssertNil(self.viewModel.error);
    XCTAssertTrue([self.viewModel.cachedItems isEqualToArray:expectedCacheItems]);
}

@end
