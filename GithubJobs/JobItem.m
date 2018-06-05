//
//  JobItem.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "JobItem.h"

@interface NSDictionary (Extensions)
- (NSString *)ext_stringWithKeypath:(NSString *)keypath;
- (NSURL *)ext_urlWithKeypath:(NSString *)keypath;
@end

@implementation NSDictionary (Extensions)
- (NSString *)ext_stringWithKeypath:(NSString *)keypath {
    if (keypath.length < 1) return nil;
    NSString *string = [self objectForKey:keypath];
    if ([string isKindOfClass:[NSString class]]) {
        return string;
    }
    return nil;
}
- (NSURL *)ext_urlWithKeypath:(NSString *)keypath {
    if (keypath.length < 1) return nil;
    NSString *urlString = [self objectForKey:keypath];
    if ([urlString isKindOfClass:[NSString class]] && urlString.length > 0) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}
@end


@implementation JobItem

+ (instancetype)importFromListItemJSON:(NSDictionary *)json {
    JobItem *obj = [JobItem new];
    obj.uid = [json ext_stringWithKeypath:@"id"];
    obj.title = [json ext_stringWithKeypath:@"title"];
    obj.company = [json ext_stringWithKeypath:@"company"];
    return obj;
}

+ (instancetype)importFromDetailItemJSON:(NSDictionary *)json {
    JobItem *obj = [JobItem new];
    obj.uid = [json ext_stringWithKeypath:@"id"];
    obj.createDateString = [json ext_stringWithKeypath:@"created_at"];
    obj.title = [json ext_stringWithKeypath:@"title"];
    obj.location = [json ext_stringWithKeypath:@"location"];
    obj.type = [json ext_stringWithKeypath:@"type"];
    obj.jobDescription = [json ext_stringWithKeypath:@"description"];
    obj.company = [json ext_stringWithKeypath:@"company"];
    obj.companyURL = [json ext_urlWithKeypath:@"company_url"];
    obj.companyLogoURL = [json ext_urlWithKeypath:@"company_logo"];
    obj.url = [json ext_urlWithKeypath:@"url"];
    
    return obj;
}

- (BOOL)isEqual:(id)object {
    if (self != nil && object != nil) {
        if (self == object) return YES;
        if ([object isKindOfClass:[JobItem class]]) {
            JobItem *item = (JobItem *)object;
            if ([self.uid isEqualToString:item.uid]) return YES;
            return [super isEqual:object];
        }
    }
    return NO;
}

// MARK: - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uid forKey:@"uid"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.createDateString forKey:@"cdate"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.jobDescription forKey:@"desc"];
    [coder encodeObject:self.company forKey:@"company"];
    [coder encodeObject:self.companyURL.absoluteString forKey:@"comurl"];
    [coder encodeObject:self.companyLogoURL.absoluteString forKey:@"comlogourl"];
    [coder encodeObject:self.url.absoluteString forKey:@"url"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        JobItem *item = self;
        item.uid = [coder decodeObjectForKey:@"uid"];
        item.title = [coder decodeObjectForKey:@"title"];
        item.createDateString = [coder decodeObjectForKey:@"cdate"];
        item.location = [coder decodeObjectForKey:@"location"];
        item.type = [coder decodeObjectForKey:@"type"];
        item.jobDescription = [coder decodeObjectForKey:@"desc"];
        item.company = [coder decodeObjectForKey:@"company"];
        if ([coder decodeObjectForKey:@"comurl"]) {
            item.companyURL = [NSURL URLWithString:[coder decodeObjectForKey:@"comurl"]];
        }
        if ([coder decodeObjectForKey:@"comlogourl"]) {
            item.companyLogoURL = [NSURL URLWithString:[coder decodeObjectForKey:@"comlogourl"]];
        }
        if ([coder decodeObjectForKey:@"url"]) {
            item.url = [NSURL URLWithString:[coder decodeObjectForKey:@"url"]];
        }
    }
    return self;
}


@end
