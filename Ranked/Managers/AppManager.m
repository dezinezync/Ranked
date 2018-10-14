//
//  AppManager.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppManager.h"

NSNotificationName const UserDidAddApp = @"com.ranked.appManager.userDidAddApp";
NSString *const kNewApp = @"com.ranked.appManager.key.newApp";

static NSString *const kAppsKey = @"com.dezinezync.ranked.key.apps";

static AppManager * sharedInstance = nil;

@interface AppManager () {
    NSArray <App *> * _apps;
}

@end

@implementation AppManager

+ (instancetype)sharedManager {
    
    if (sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[AppManager alloc] init];
        });
    }
    
    return sharedInstance;
    
}

#pragma mark - Apps

- (NSArray <App *> * _Nonnull)apps {
    
    if (_apps == nil) {
        
        NSArray <NSDictionary *> *members = [[NSUserDefaults standardUserDefaults] objectForKey:kAppsKey];
        
        if (!members) {
            members = @[];
            
            return (NSArray <App *> *)members;
        }
        
        NSMutableArray *apps = [NSMutableArray arrayWithCapacity:members.count];
        
        for (NSDictionary *dict in members) {
            
            App *app = [App instanceFromDictionary:dict];
            
            [apps addObject:app];
            
        }
        
        _apps = apps.copy;
        
    }
    
    return _apps;
    
}

- (void)setApps:(NSArray<App *> *)apps {
    
    _apps = apps;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (_apps == nil) {
        [defaults setObject:@[] forKey:kAppsKey];
        [defaults synchronize];
        return;
    }
    
    NSMutableArray *members = [NSMutableArray arrayWithCapacity:_apps.count];
    
    for (App *app in apps) {
        
        NSDictionary *dict = [app dictionaryRepresentation];
        
        [members addObject:dict];
        
    }
    
    [defaults setObject:members forKey:kAppsKey];
    
}

- (void)addApp:(App *)app {
    
    if (app == nil) {
        return;
    }
    
    NSArray *apps = [[self apps] arrayByAddingObject:app];
    
    self.apps = apps;
    
}

#pragma mark -

- (void)save {
    
    [self setApps:self.apps];
    
}

@end
