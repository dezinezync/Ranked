//
//  ImageCache.m
//  Ranked
//
//  Created by Nikhil Nigade on 16/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "ImageCache.h"
#import "NSString+MD5.h"

@interface ImageCache ()

@property (nonatomic, copy) NSString *cachePath;
@property (nonatomic, nullable) dispatch_queue_t writeQueue, readQueue;
@property (nonatomic, weak) NSFileManager *fileManager;

@end

@implementation ImageCache

- (instancetype)init {
    
    if (self = [super init]) {
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.cachePath = [paths[0] stringByAppendingPathComponent:@"diskCache"];
        
        // write only one file at a time to prevent memspace corruption
        self.writeQueue = dispatch_queue_create("com.ranked.imageCache.writeQueue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_sync(self.writeQueue, ^{
            self.fileManager = [NSFileManager defaultManager];
        });
        
        // read multiple files at any given point of time
        self.readQueue = dispatch_queue_create("com.ranked.PDC.readQueue", DISPATCH_QUEUE_CONCURRENT);
        
        // create the data folder on disk if it doesn't exist. Do this as early as possible
        dispatch_sync(self.writeQueue, ^{
            [self _createLocalFolder];
        });
    }
    
    return self;
    
}

- (void)_createLocalFolder {
    if ([self.fileManager fileExistsAtPath:self.cachePath] == NO) {
        [self.fileManager createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (void)objectforKey:(NSString *)key callback:(void (^ _Nullable)(UIImage * _Nullable))cb {
    
    // since we are not returning back to anyone, there is no use calling for it.
    if (!cb)
        return;
    
    key = [(NSString *)key md5];
    
    UIImage *retval = [super objectForKey:key];
    
    if (retval)
        cb(retval);
    else {
        // check with disk cache
        [self objectForKeyOnDisk:key callback:cb];
    }
    
}

- (void)setObject:(UIImage *)obj data:(NSData *)data forKey:(NSString *)key
{
    BOOL stored = NO;
    
    if ([obj isKindOfClass:UIImage.class]) {
        UIImage *image = (UIImage *)obj;
        NSUInteger cost = image.size.height * image.size.width * image.scale * image.scale;
        [self setObject:obj data:data forKey:key cost:cost];
        stored = YES;
    }
    
    if (stored)
        return;
    
    key = [(NSString *)key md5];
    
    [super setObject:obj forKey:key];
    
    // store on disk cache
    // set inside our disk cache
    if (!data && obj)
        data = UIImagePNGRepresentation(obj);
    
    [self setObjectToDisk:data forKey:key];
}

- (void)setObject:(UIImage *)obj data:(NSData *)data forKey:(NSString *)key cost:(NSUInteger)g
{
    
    key = [(NSString *)key md5];
    
    [super setObject:obj forKey:key cost:g];
    
    // set inside our disk cache
    if (data == nil && obj)
        data = UIImagePNGRepresentation(obj); //assume PNG if we dont have the source
    
    if (data != nil) {
        [self setObjectToDisk:data forKey:key];
    }
}

- (void)removeObjectForKey:(NSString *)key
{
    key = [(NSString *)key md5];
    
    [super removeObjectForKey:key];
}

#pragma mark -

- (void)setObjectToDisk:(id)obj forKey:(NSString *)key {
    
    dispatch_async(self.writeQueue, ^{
        
        NSString *path = [self.cachePath stringByAppendingPathComponent:key];
        
        if ([self.fileManager fileExistsAtPath:path] == NO) {
            [self.fileManager createFileAtPath:path contents:obj attributes:@{NSURLIsExcludedFromBackupKey: @(YES)}];
        }
        
    });
    
}

- (void)objectForKeyOnDisk:(NSString *)key callback:(void (^ _Nullable)(UIImage *image))cb {
    
    if (!cb)
        return;
    
    dispatch_async(self.readQueue, ^{
        
        NSString *path = [self.cachePath stringByAppendingPathComponent:key];
        // exit early if we cannot respond back.
        
        if ([self.fileManager fileExistsAtPath:path]) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            cb(image);
        }
        else
            cb(nil);
        
    });
    
}

@end
