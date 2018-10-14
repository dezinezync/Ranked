//
//  Country.m
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "Country.h"
#import "macros.h"

NSString * countryFlagEmoji (NSString *shortCode) {
    if(shortCode.length != 2) {
        @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:@"Expecting ISO country code" userInfo:nil];
    }
    
    int base = 0x1F1E6 - 0x41;
    
    wchar_t bytes[2] = {
        base + [shortCode characterAtIndex:0],
        base + [shortCode characterAtIndex:1]
    };
    
    return [[NSString alloc] initWithBytes:bytes
                                    length:shortCode.length * sizeof(wchar_t)
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

@interface Country ()

@property (class, nonatomic, strong) NSCache *flagCache;

@end

static NSCache * _flagCache = nil;

@implementation Country

+ (instancetype)instanceFromDictionary:(NSDictionary *)dict forCode:(nonnull NSString *)code {
    Country *instance = [[Country alloc] initWithDictionary:dict forCode:code];
    
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict  forCode:(nonnull NSString *)code {
    
    if (self = [super init]) {
        self.shortCode = code;
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

/*
 if (self.<#keyname#> != nil) {
 [dict setValue:self.<#keyname#> forKey:propSel(<#keyname#>)];
 }
 */
- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary * dict = @{}.mutableCopy;
    
    if (self.name != nil) {
        [dict setValue:self.name forKey:propSel(name)];
    }
    
    if (self.shortCode != nil) {
        [dict setValue:self.shortCode forKey:propSel(shortCode)];
    }
    
    if (self.storeFrontID != nil) {
        [dict setValue:self.storeFrontID forKey:propSel(storeFrontID)];
    }
    
    return dict;
    
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:propSel(name)];
    [aCoder encodeObject:self.shortCode forKey:propSel(shortCode)];
    [aCoder encodeObject:self.storeFrontID forKey:propSel(storeFrontID)];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:propSel(name)];
        self.shortCode = [aDecoder decodeObjectForKey:propSel(shortCode)];
        self.storeFrontID = [aDecoder decodeObjectForKey:propSel(storeFrontID)];
    }
    
    return self;
    
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (object == nil) {
        return NO;
    }
    
    if ([object isKindOfClass:Country.class]) {
        return [self isEqualToCountry:object];
    }
    
    return NO;
}

// What is political correctness?  ¯\_(ツ)_/¯
- (BOOL)isEqualToCountry:(Country *)country {
    if (country == nil) {
        return NO;
    }
    
    if ([country.shortCode isEqualToString:self.shortCode]) {
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (UIImage *)flagImage {
 
    UIImage *image = [[Country flagCache] objectForKey:self.shortCode];
 
    if (image == nil) {
        NSString *flag = countryFlagEmoji(self.shortCode);
        
        image = [flag imageWithSide:40.f];
        
        [[Country flagCache] setObject:image forKey:self.shortCode];
    }
    
    return image;
    
}

#pragma mark - Class Properties

+ (NSCache *)flagCache {
    if (_flagCache == nil) {
        _flagCache = [[NSCache alloc] init];
        _flagCache.name = @"com.ranked.cache.flagImages";
        _flagCache.totalCostLimit = 100;
    }
    return _flagCache;
}

@end
