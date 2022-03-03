//
//  KTVHCDataManager.m
//  KTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "KTVHCDataStorage.h"
#import "KTVHCData+Internal.h"
#import "KTVHCDataUnitPool.h"
#import "KTVHCLog.h"

@interface KTVHCDataStorage()<NSLocking>
@property (nonatomic, strong) NSRecursiveLock *coreLock;
@end

@implementation KTVHCDataStorage

+ (instancetype)storage
{
    static KTVHCDataStorage *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.maxCacheLength = 500 * 1024 * 1024;
        self.maxCacheAge = 7 * 24 * 60 * 60;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeExpiredCacheIfNeed) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)removeExpiredCacheIfNeed
{
    NSArray<KTVHCDataUnit *> *allUnit = [[KTVHCDataUnitPool pool] allCacheDataUnit];
    NSTimeInterval time = [[NSDate new] timeIntervalSince1970];
    [self lock];
    for (KTVHCDataUnit *unit in allUnit) {
        if (unit.totalLength == unit.cacheLength && unit.createTimeInterval + self.maxCacheAge < time){
            [[KTVHCDataUnitPool pool] deleteUnitWithURL:unit.URL];
        }
    }
    [self unlock];
}

- (NSURL *)completeFileURLWithURL:(NSURL *)URL
{
    KTVHCDataUnit *unit = [[KTVHCDataUnitPool pool] unitWithURL:URL];
    NSURL *completeURL = unit.completeURL;
    [unit workingRelease];
    return completeURL;
}

- (KTVHCDataReader *)readerWithRequest:(KTVHCDataRequest *)request
{
    if (!request || request.URL.absoluteString.length <= 0) {
        KTVHCLogDataStorage(@"Invaild reader request, %@", request.URL);
        return nil;
    }
    KTVHCDataReader *reader = [[KTVHCDataReader alloc] initWithRequest:request];
    return reader;
}

- (KTVHCDataLoader *)loaderWithRequest:(KTVHCDataRequest *)request
{
    if (!request || request.URL.absoluteString.length <= 0) {
        KTVHCLogDataStorage(@"Invaild loader request, %@", request.URL);
        return nil;
    }
    KTVHCDataLoader *loader = [[KTVHCDataLoader alloc] initWithRequest:request];
    return loader;
}

- (KTVHCDataCacheItem *)cacheItemWithURL:(NSURL *)URL
{
    return [[KTVHCDataUnitPool pool] cacheItemWithURL:URL];
}

- (NSArray<KTVHCDataCacheItem *> *)allCacheItems
{
    return [[KTVHCDataUnitPool pool] allCacheItem];
}

- (void)cacheVideoWithURL:(NSURL *)URL videoPath:(NSString *)path
{
    [[KTVHCDataUnitPool pool] cacheVideoWithURL:URL videoPath:path];
}

- (long long)totalCacheLength
{
    return [[KTVHCDataUnitPool pool] totalCacheLength];
}

- (void)deleteCacheWithURL:(NSURL *)URL
{
    [[KTVHCDataUnitPool pool] deleteUnitWithURL:URL];
}

- (void)deleteAllCaches
{
    [[KTVHCDataUnitPool pool] deleteAllUnits];
}

- (BOOL)hasCacheWithURL:(NSURL *)URL
{
    return [[KTVHCDataUnitPool pool] hasCacheWithURL:URL];
}

- (BOOL)hasAvailableDataForURL:(NSURL *)URL
{
    return [[KTVHCDataUnitPool pool] hasAvailableDataForURL:URL];
}

#pragma mark - NSLocking
- (void)lock
{
    if (!self.coreLock) {
        self.coreLock = [[NSRecursiveLock alloc] init];
    }
    [self.coreLock lock];
}

- (void)unlock
{
    [self.coreLock unlock];
}


@end
