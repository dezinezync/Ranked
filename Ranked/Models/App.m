//
//  App.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "App.h"
#import "macros.h"

#import "TunesManager.h"

@implementation App

+ (instancetype)instanceFromDictionary:(NSDictionary *)dict {
    
    App *instance = [[App alloc] initWithDictionary:dict];
    
    return instance;
    
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    if (self = [super init]) {
        [self setup];
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
    
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.artwork = @{};
    self.countries = [NSOrderedSet orderedSetWithArray:@[@"AU", @"AT", @"CA", @"CN", @"FR", @"DE", @"GB", @"HK", @"IN", @"IT", @"JP", @"MX", @"NL", @"SG", @"US"]];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    for (NSString *code in self.countries) {
        dict[code] = @0;
    }
    
    self.rankings = dict;
    
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.appID forKey:propSel(appID)];
    [aCoder encodeObject:self.developerID forKey:propSel(developerID)];
    [aCoder encodeObject:self.developer forKey:propSel(developer)];
    [aCoder encodeObject:self.artwork forKey:propSel(artwork)];
    [aCoder encodeObject:self.genre forKey:propSel(genre)];
    [aCoder encodeObject:self.genreName forKey:propSel(genreName)];
    [aCoder encodeObject:self.name forKey:propSel(name)];
    [aCoder encodeObject:self.url forKey:propSel(url)];
    [aCoder encodeObject:self.countries forKey:propSel(countries)];
    [aCoder encodeObject:self.rankings forKey:propSel(rankings)];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        self.appID = [aDecoder decodeObjectForKey:propSel(appID)];
        self.developerID = [aDecoder decodeObjectForKey:propSel(developerID)];
        self.developer = [aDecoder decodeObjectForKey:propSel(developer)];
        self.artwork = [aDecoder decodeObjectForKey:propSel(artwork)];
        self.genre = [aDecoder decodeObjectForKey:propSel(genre)];
        self.genreName = [aDecoder decodeObjectForKey:propSel(genreName)];
        self.name = [aDecoder decodeObjectForKey:propSel(name)];
        self.url = [aDecoder decodeObjectForKey:propSel(url)];
        self.countries = [aDecoder decodeObjectForKey:propSel(countries)];
        self.rankings = [aDecoder decodeObjectForKey:propSel(rankings)];
    }
    
    return self;
    
}

#pragma mark - KVC

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:propSel(countries)] && [value isKindOfClass:NSArray.class]) {
        
        value = [NSOrderedSet orderedSetWithArray:value];
        
    }
    
    if (([key isEqualToString:propSel(rankings)]
        || [key isEqualToString:propSel(oldRankings)])
        && [value isKindOfClass:NSMutableDictionary.class] == NO) {
        
        value = [value mutableCopy];
        
    }
    
    [super setValue:value forKey:key];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"trackId"]) {
        self.appID = value;
    }
    else if ([key isEqualToString:@"artistId"]) {
        self.developerID = value;
    }
    else if ([key isEqualToString:@"sellerName"]) {
        self.developer = value;
    }
    else if ([key isEqualToString:@"primaryGenreId"]) {
        self.genre = @([value integerValue]);
    }
    else if ([key isEqualToString:@"primaryGenreName"]) {
        self.genreName = value;
    }
    else if ([key isEqualToString:@"trackName"]) {
        self.name = value;
    }
    else if ([key isEqualToString:@"trackViewUrl"]) {
        
        if ([value isKindOfClass:NSURL.class]) {
            self.url = value;
        }
        else {
            self.url = [NSURL URLWithString:value];
        }
        
    }
    else if ([key containsString:@"artworkUrl"]) {
        
        key = [key stringByReplacingOccurrencesOfString:@"artworkUrl" withString:@""];
        NSMutableDictionary *dict = (self.artwork ?: @{}).mutableCopy;
        
        if ([value isKindOfClass:NSString.class]) {
            dict[key] = [NSURL URLWithString:value];
        }
        else {
            dict[key] = value;
        }
        
        self.artwork = dict.copy;
        
    }
    else {
        // prevent super call. This will crash the app.
    }
    
}

#pragma mark -

/*
if (self.<#keyname#> != nil) {
 [dict setValue:self.<#keyname#> forKey:propSel(<#keyname#>)];
}
 */

- (NSDictionary *)dictionaryRepresentation {
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    
    if (self.appID != nil) {
        [dict setValue:self.appID forKey:propSel(appID)];
    }
    
    if (self.developerID != nil) {
        [dict setValue:self.developerID forKey:propSel(developerID)];
    }
    
    if (self.developer != nil) {
        [dict setValue:self.developer forKey:propSel(developer)];
    }
    
    if (self.artwork != nil) {
        
        [self.artwork enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURL * _Nonnull obj, BOOL * _Nonnull stop) {
           
            NSString *substitute = [NSString stringWithFormat:@"artworkUrl%@", key];
            
            if ([obj isKindOfClass:NSURL.class]) {
                [dict setValue:[obj absoluteString] forKey:substitute];
            }
            else {
                [dict setValue:obj forKey:substitute];
            }
            
        }];
        
    }
    
    if (self.genre != nil) {
        [dict setValue:self.genre forKey:propSel(genre)];
    }
    
    if (self.genreName != nil) {
        [dict setValue:self.genreName forKey:propSel(genreName)];
    }
    
    if (self.name != nil) {
        [dict setValue:self.name forKey:propSel(name)];
    }
    
    if (self.url != nil) {
        if ([self.url isKindOfClass:NSURL.class]) {
            [dict setValue:self.url.absoluteString forKey:propSel(url)];
        }
        else {
            [dict setValue:self.url forKey:propSel(url)];
        }
    }
    
    if (self.countries) {
        [dict setObject:self.countries.array forKey:propSel(countries)];
    }
    
    if (self.rankings) {
        [dict setObject:self.rankings forKey:propSel(rankings)];
    }
    
    return dict.copy;
    
}

#pragma mark - Equality

- (NSUInteger)hash {
    
    __block NSUInteger hash = 0;
    
    [self.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        hash += [key hash];
        hash += [obj hash];
        
    }];
    
    return hash;
    
}

- (BOOL)isEqual:(id)object {
    if (object == nil) {
        return NO;
    }
    
    if ([object isKindOfClass:App.class]) {
        return [self isEqualToApp:object];
    }
    
    return NO;
}

- (BOOL)isEqualToApp:(App *)app {
    if (app == nil) {
        return NO;
    }
    
    if (app.hash == self.hash) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Setter Overrides

- (void)setRankings:(NSMutableDictionary <NSString *,NSNumber *> *)rankings {

    if (_rankings != nil) {
        self.oldRankings = [_rankings mutableCopy];
    }
    
    // ensure the copy is mutable
    @try {
        rankings[@"__test"] = @(0);
        [rankings removeObjectForKey:@"__test"];
    }
    @catch (NSException *exc) {
        rankings = [rankings mutableCopy];
    }
    
    _rankings = rankings;
    
}

- (void)setCountries:(NSOrderedSet <NSString *> *)countries {
    
    NSPointerArray *mapped = [NSPointerArray weakObjectsPointerArray];
    
    TunesManager *manager = [TunesManager sharedManager];
    
    for (NSString *code in countries) {
        
        Country *country = [manager countryForCode:code];
        
        if (country) {
            [mapped addPointer:(__bridge void * _Nullable)(country)];
        }
        
    }
    
    self.trackedCountries = mapped;
    
    _countries = countries;
}

@end
