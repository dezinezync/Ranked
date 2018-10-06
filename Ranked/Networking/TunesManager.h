//
//  TunesManager.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a shared interface to handle all the iTunes API Networking.
 * All methods return a NSURLSessionTask which is started by default.
 */
@interface TunesManager : NSObject

+ (instancetype)sharedManager;

- (NSURLSessionTask *)searchForApp:(NSString *)title success:(void(^ _Nullable)(NSDictionary * responseObject))successCB error:(void(^ _Nullable)(NSError *error))errorCB;

@end

NS_ASSUME_NONNULL_END
