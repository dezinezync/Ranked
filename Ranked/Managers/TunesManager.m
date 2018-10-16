//
//  TunesManager.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "TunesManager.h"

static NSTimeInterval const kTimeoutInterval = 60;

static TunesManager * sharedInstance = nil;

@interface TunesManager ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong, readwrite) dispatch_queue_t queue;

@property (nonatomic, strong, readwrite) ImageCache *imageCache;

@property (nonatomic, strong, readwrite) NSOrderedSet <Country *> *countries;

- (NSURLSessionTask *)rankForApp:(App *)app countryCode:(NSString *)code success:(void(^ _Nullable)(NSNumber *))successCB error:(void(^ _Nullable)(NSError *error))errorCB;

@end

@implementation TunesManager

+ (instancetype)sharedManager {
    
    if (sharedInstance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[TunesManager alloc] init];
        });
    }
    
    return sharedInstance;
    
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.waitsForConnectivity = NO;
        config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        config.timeoutIntervalForRequest = 30;
        config.allowsCellularAccess = YES;
        config.HTTPShouldUsePipelining = YES;
        config.HTTPShouldSetCookies = YES;
        config.HTTPMaximumConnectionsPerHost = 10;
        config.URLCache = [NSURLCache sharedURLCache];
        
        self.session = [NSURLSession sessionWithConfiguration:config];
        self.session.sessionDescription = @"Ranked's base networking session used by it's TunesManager class.";
        
        self.queue = dispatch_queue_create("com.ranked.tunesManager", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
    
}

#pragma mark -

- (NSURLSessionTask *)searchForApp:(NSString *)title success:(void (^)(NSArray <App *> * _Nonnull))successCB error:(void (^)(NSError * _Nonnull))errorCB {
    
    __block NSURLSessionTask *task = nil;
    
    dispatch_sync(self.queue, ^{
       
        NSString *encodedTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        NSString *path = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/search?term=%@&country=US&entity=software,iPadSoftware&limit=25", encodedTitle];
        
        NSURL *url = [NSURL URLWithString:path];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInterval];
        
        task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (error) {
                
                if (errorCB) {
                    errorCB(error);
                }
                
                return;
                
            }
            
            if (!successCB) {
                return;
            }
            
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error) {
                
                if (errorCB) {
                    errorCB(error);
                }
                
                return;
                
            }
            
            /**
             {
             resultCount: Number,
             results: Array <Object>
             }
             */
            
            if ([[responseObject valueForKey:@"resultCount"] integerValue] == 0) {
#warning TODO: handle empty state.
                return;
            }
            
            // we have results
            NSArray <NSDictionary *> * results = [responseObject objectForKey:@"results"];
            
            // we're only interested in a few keys from the results
            NSMutableArray <App *> *retval = [NSMutableArray arrayWithCapacity:results.count];
            
            for (NSDictionary *obj in results) {
                
                App *app = [App instanceFromDictionary:obj];
                
                [retval addObject:app];
                
            }
            
            if (successCB) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successCB(retval.copy);
                });
            }
            
        }];
        
        [task resume];
        
    });
    
    return task;
    
}

- (void)ranksForApp:(App *)app progress:(void (^)(NSString * _Nonnull, NSNumber * _Nonnull))progressCB success:(void (^)(NSDictionary <NSString *, NSNumber *> * _Nonnull))successCB error:(void (^)(NSError * _Nonnull))errorCB {
    
    // this can mutate at any time
    // so we keep a copy of it
    NSArray *countries = app.countries.copy;
    
    if (countries.count == 0) {
        successCB(@{});
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSMutableDictionary <NSString *, id> *taskResponses = @{}.mutableCopy;
        NSMutableArray <NSURLSessionTask *> *tasks = [NSMutableArray arrayWithCapacity:countries.count];
        
        for (NSString *obj in countries) { @autoreleasepool {
            
            NSURLSessionTask *task = [self rankForApp:app countryCode:obj success:^(NSNumber * rank) {
                
                taskResponses[obj] = rank;
                
                if (progressCB) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressCB(obj, rank);
                    });
                }
                
                dispatch_semaphore_signal(semaphore);
                
            } error:^(NSError *error) {
                
                if (errorCB) {
                    errorCB(error);
                }
                
                dispatch_semaphore_signal(semaphore);
                
            }];
            
            [task resume];
            
            [tasks addObject:task];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
        } }
        
        // all the above tasks have completed
        if (successCB) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                successCB(taskResponses);
                
            });
        }
    });
    
}

- (NSURLSessionTask *)rankForApp:(App *)app countryCode:(NSString *)code success:(void (^)(NSNumber *))successCB error:(void (^)(NSError *))errorCB {
    
    NSString *path = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/%@/rss/topfreeapplications/limit=200/genre=%@/json", [code lowercaseString], app.genre];
    NSLog(@"%@", path);
    NSURL *url = [NSURL URLWithString:path];
    
    NSString *appID = [app.appID stringValue];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInterval];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            if (errorCB) {
                errorCB(error);
            }
            
            return;
            
        }
        
        if (!successCB) {
            return;
        }
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error) {
            
            if (errorCB) {
                errorCB(error);
            }
            
            return;
            
        }
        
        NSArray <NSDictionary *> *entries = nil;
        @try {
            entries = responseObject[@"feed"][@"entry"];
        }
        @catch (NSException *exc) {
            entries = @[];
        }
        
        __block NSInteger rank = 0;
        
        [entries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *identifier = obj[@"id"][@"attributes"][@"im:id"];
            
            if ([identifier isEqualToString:appID]) {
                rank = idx + 1;
                *stop = YES;
            }
            
        }];
        
        successCB(@(rank));
         
    }];
    
    return task;
    
}

#pragma mark - Getters

- (ImageCache *)imageCache {
    
    if (_imageCache == nil) {
        _imageCache = [[ImageCache alloc] init];
        _imageCache.name = @"com.ranked.cache.imageCache";
    }
    
    return _imageCache;
    
}

- (NSOrderedSet <Country *> *)countries {
    
    if (!_countries) {
        
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
        
        if (filepath != nil) {
            NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filepath];
            
            NSDictionary <NSString *, NSDictionary *> *list = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
            
            NSMutableArray *members = [[NSMutableArray alloc] initWithCapacity:list.allKeys.count];
            
            [list enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
               
                Country *instance = [Country instanceFromDictionary:obj forCode:key];
                
                [members addObject:instance];
                
            }];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)];
            NSArray *sorted = [members sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            // sort using shortCode
            NSOrderedSet *set = [[NSOrderedSet alloc] initWithArray:sorted];
            
            _countries = set;
            
        }
        
    }
    
    return _countries;
    
}

- (Country *)countryForCode:(NSString *)shortCode {
    
    if (shortCode == nil || shortCode.length != 2) {
#ifdef DEBUG
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"shortCode should be of 2 characters" userInfo:nil];
#else
        return nil;
#endif
    }
    
    __block Country *country = nil;
    
    [self.countries enumerateObjectsUsingBlock:^(Country * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj.shortCode isEqualToString:shortCode]) {
            country = obj;
            *stop = YES;
        }
        
    }];
    
    return country;
    
}

#pragma mark -

- (NSURLSessionTask *)imageForURL:(NSURL *)url size:(CGSize)size success:(void (^)(UIImage * _Nullable))successCB error:(void (^)(NSError * _Nonnull))errorCB {
    
    if (url == nil) {
        if (errorCB) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:@{NSURLErrorFailingURLStringErrorKey: url ?: @""}];
            errorCB(error);
        }
        return nil;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block UIImage *image = nil;
    
    [self.imageCache objectforKey:url.absoluteString callback:^(UIImage * _Nullable obj) {
       
        image = obj;
        
        dispatch_semaphore_signal(semaphore);
        
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successCB(image);
        });
        
        return nil;
    }
    
    NSURLSessionTask * task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            if (errorCB) {
                errorCB(error);
            }
            
            return;
        }
        
        if (successCB == nil) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data != nil && [data length] > 4) {
                image = [[UIImage alloc] initWithData:data scale:UIScreen.mainScreen.scale];
                
                if (image) {
                    [self.imageCache setObject:image data:data forKey:url.absoluteString];
                }
            }
            
            successCB(image);
            
        });
        
    }];
    
    [task resume];
    
    return task;
    
}

@end
