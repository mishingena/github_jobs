//
//  CacheService.h
//  GithubJobs
//
//  Created by Gena on 05.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheService : NSObject

@property (nonatomic, strong) NSString *filePath;
+ (NSString *)documentsPath;

- (void)fetchContentsWithCompletion:(void(^)(id contents))completion;
- (void)updateContents:(id)contents completion:(void(^)(BOOL success))completion;

@end
