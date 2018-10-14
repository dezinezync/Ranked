//
//  AppManager.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "App.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a shared interface all local storage interfaces.
 * It currently uses NSUserDefaults to persist data to disk.
 */
@interface AppManager : NSObject

+ (instancetype)sharedManager;

#pragma mark -

@property (nonatomic, copy) NSArray <App *> *apps;

- (void)addApp:(App * _Nonnull)app;

// Save any modifications to the disk.
// This will fire the KVO for the app key.
- (void)save;

@end

NS_ASSUME_NONNULL_END
