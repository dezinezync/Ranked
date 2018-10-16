//
//  ImageCache.h
//  Ranked
//
//  Created by Nikhil Nigade on 16/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCache : NSCache

- (void)objectforKey:(NSString *)key callback:(void (^ _Nullable)(UIImage * _Nullable))cb;

- (void)setObject:(UIImage *)obj data:(NSData *)data forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
