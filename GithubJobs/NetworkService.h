//
//  NetworkService.h
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkService : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)GET:(NSURL *)url completion:(void(^)(id json, NSError *error))completion;

@end
