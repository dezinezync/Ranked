//
//  App.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface App : NSObject <NSCoding>

@property (nonatomic, copy) NSString *developerID;
@property (nonatomic, copy) NSString *developer;
@property (nonatomic, strong) NSDictionary <NSString *, NSURL *> *artwork; // keys are 100, 60 and 512. None are guaranteed to be present.
@property (nonatomic, copy) NSNumber *genre;
@property (nonatomic, copy) NSString *genreName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *url;

+ (instancetype)instanceFromDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
