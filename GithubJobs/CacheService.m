//
//  CacheService.m
//  GithubJobs
//
//  Created by Gena on 05.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "CacheService.h"

@interface CacheService ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation CacheService

- (NSOperationQueue *)queue {
    if (!_queue) {
        NSOperationQueue *queue = [NSOperationQueue new];
        queue.maxConcurrentOperationCount = 1;
        queue.name = @"CacheQueue";
        _queue = queue;
    }
    return _queue;
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)documentsPath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (void)fetchContentsWithCompletion:(void (^)(id))completion {
    if (self.filePath.length < 1) {
        if (completion) completion(nil);
    }
    
    __weak typeof(self) wSelf = self;
    [self.queue addOperationWithBlock:^{
        typeof(self) self = wSelf;
        id contents = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (completion) completion(contents);
        }];
    }];
}

- (void)updateContents:(id)contents completion:(void (^)(BOOL))completion {
    if (self.filePath.length < 1 || contents == nil) {
        if (completion) completion(NO);
    }
    
    __weak typeof(self) wSelf = self;
    [self.queue addOperationWithBlock:^{
        typeof(self) self = wSelf;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:contents];
        BOOL written = [data writeToFile:self.filePath atomically:YES];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (completion) completion(written);
        }];
    }];
}

@end
