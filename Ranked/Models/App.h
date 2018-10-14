//
//  App.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Country.h"

NS_ASSUME_NONNULL_BEGIN

@interface App : NSObject <NSCoding>

@property (nonatomic, copy) NSNumber *appID; 
@property (nonatomic, copy) NSString *developerID;
@property (nonatomic, copy) NSString *developer;
@property (nonatomic, strong) NSDictionary <NSString *, NSURL *> *artwork; // keys are 100, 60 and 512. None are guaranteed to be present.
@property (nonatomic, copy) NSNumber *genre;
@property (nonatomic, copy) NSString *genreName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *url;

// list of country codes for which the app tracks it's rankings.
// this allows for different apps to have different trackings.
@property (nonatomic, strong) NSOrderedSet <NSString *> * countries;

// this dict is persisted to disk
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *rankings;

// this is not persisted to the disk. It's only avilable during the lifecycle of the app.
// when rankings are reloaded, the value from rankings is assigned to this list
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *oldRankings;

// same as the above but is mapped to a country object.The object is weakly held.
// do not mutate this directly.
@property (nonatomic, strong) NSPointerArray *trackedCountries;

+ (instancetype)instanceFromDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

- (BOOL)isEqualToApp:(App *)app;

@end

NS_ASSUME_NONNULL_END
