//
//  KTVHCDataManager.h
//  KTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTVHCDataReader.h"
#import "KTVHCDataLoader.h"
#import "KTVHCDataRequest.h"
#import "KTVHCDataResponse.h"
#import "KTVHCDataCacheItem.h"

@interface KTVHCDataStorage : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)storage;

/**
 *  Return file path if the content did finished cache.
 */
- (NSURL *)completeFileURLWithURL:(NSURL *)URL;

/**
 *  Reader for certain request.
 */
- (KTVHCDataReader *)readerWithRequest:(KTVHCDataRequest *)request;

/**
 *  Loader for certain request.
 */
- (KTVHCDataLoader *)loaderWithRequest:(KTVHCDataRequest *)request;

/**
 *  Get cache item.
 */
- (KTVHCDataCacheItem *)cacheItemWithURL:(NSURL *)URL;
- (NSArray<KTVHCDataCacheItem *> *)allCacheItems;

/**
 *  Create the cache item for the URL.
 *
 *  @param URL : The URL for HTTP content.
 *  @param path : The video path.
 */
- (void)cacheVideoWithURL:(NSURL *)URL videoPath:(NSString *)path;

/**
 *  Has cache for URL.
 *
 *  @param URL : The URL for HTTP content.
 */
- (BOOL)hasCacheWithURL:(NSURL *)URL;

/**
 *  Has available data
 *
 *  @param URL : The URL for HTTP content.
 */
- (BOOL)hasAvailableDataForURL:(NSURL *)URL;

/**
 *  Get cache length.
 */
@property (nonatomic) long long maxCacheLength;     // Default is 500M.
- (long long)totalCacheLength;

/**
 *  Max cache age，default a week，value  7*24*60*60
 */
@property (nonatomic) long long maxCacheAge;

/**
 *  Delete cache.
 */
- (void)deleteCacheWithURL:(NSURL *)URL;
- (void)deleteAllCaches;



@end
