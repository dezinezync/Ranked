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

- (NSURLSessionTask *)searchForApp:(NSString *)title success:(void (^)(NSDictionary * _Nonnull))successCB error:(void (^)(NSError * _Nonnull))errorCB {
    
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
        
        NSDictionary *retval = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error) {
            
            if (errorCB) {
                errorCB(error);
            }
            
            return;
            
        }
        
        if (successCB) {
            successCB(retval);
        }
        
    }];
    
    [task resume];
    
    return task;
    
}

@end
