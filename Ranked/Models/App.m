//
//  App.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "App.h"
#import "macros.h"

@implementation App

+ (instancetype)instanceFromDictionary:(NSDictionary *)dict {
    
    App *instance = [[App alloc] initWithDictionary:dict];
    
    return instance;
    
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
    
}

- (instancetype)init {
    if (self = [super init]) {
        self.artwork = @{};
    }
    
    return self;
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
    }
    
    return self;
    
}

#pragma mark - KVC

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
    
    return dict.copy;
    
}

#pragma mark - Equality

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
    
    if ([app.developerID isEqualToString:self.developerID]
        && [app.appID isEqualToNumber:self.appID]) {
        return YES;
    }
    
    return NO;
}

@end
