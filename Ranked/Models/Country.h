//
//  Country.h
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+UIImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface Country : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *shortCode;
@property (nonatomic, copy) NSNumber *storeFrontID;

- (BOOL)isEqualToCountry:(Country *)country;

+ (instancetype)instanceFromDictionary:(NSDictionary *)dict forCode:(NSString *)code;

- (instancetype)initWithDictionary:(NSDictionary *)dict forCode:(NSString *)code;

- (NSDictionary *)dictionaryRepresentation;

- (UIImage *)flagImage;

@end

NS_ASSUME_NONNULL_END
