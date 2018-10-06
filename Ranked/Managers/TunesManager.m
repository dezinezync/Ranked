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

#pragma mark -

- (NSURLSessionTask *)searchForApp:(NSString *)title success:(void (^)(NSArray <App *> * _Nonnull))successCB error:(void (^)(NSError * _Nonnull))errorCB {
    
    title = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *path = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/search?term=%@&country=US&entity=software,iPadSoftware&limit=25", title];
    
    NSURL *url = [NSURL URLWithString:path];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInterval];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
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
            successCB(retval.copy);
        }
        
    }];
    
    [task resume];
    
    return task;
    
}

@end
