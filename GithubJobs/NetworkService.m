//
//  NetworkService.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "NetworkService.h"

@interface NetworkService () <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSOperationQueue *queue;
@end


@implementation NetworkService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *queue = [NSOperationQueue new];
        queue.name = @"NetworkServiceQueue";
        _queue = queue;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

- (NSURLSessionDataTask *)GET:(NSURL *)url completion:(void (^)(id, NSError *))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, error);
            });
            return;
        }
        
        id json = nil;
        NSError *jsonError = nil;
        if (data != nil) {
            json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(json, jsonError);
        });
    }];
    [dataTask resume];
    return dataTask;
}

@end
