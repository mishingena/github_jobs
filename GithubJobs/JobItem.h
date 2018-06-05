//
//  JobItem.h
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *createDateString;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *jobDescription;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSURL *companyURL;
@property (nonatomic, strong) NSURL *companyLogoURL;
@property (nonatomic, strong) NSURL *url;

+ (instancetype)importFromListItemJSON:(NSDictionary *)json;
+ (instancetype)importFromDetailItemJSON:(NSDictionary *)json;

@end
