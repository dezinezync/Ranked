//
//  TunesManager.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppManager.h"
#import "App.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a shared interface to handle all the iTunes API Networking.
 * All methods return a NSURLSessionTask which is started by default.
 */
@interface TunesManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) NSOrderedSet <Country *> *countries;

- (Country *)countryForCode:(NSString *)shortCode;

#pragma mark - Search

- (NSURLSessionTask *)searchForApp:(NSString *)title success:(void(^ _Nullable)(NSArray <App *> * responseObject))successCB error:(void(^ _Nullable)(NSError *error))errorCB;

#pragma mark - Rankings

/**
 * This data is not app specific and is valid for all apps.
 * Only the country short codes are used for making the requests.
 * The App's reference is used to update rankings directly for that app.
 */
- (void)ranksForApp:(App *)app progress:(void(^ _Nullable)(NSString *shortCode, NSNumber * rank))progressCB success:(void(^ _Nullable)(NSDictionary <NSString *, NSNumber *> * responseObjects))successCB error:(void(^ _Nullable)(NSError *error))errorCB;

@end

NS_ASSUME_NONNULL_END
