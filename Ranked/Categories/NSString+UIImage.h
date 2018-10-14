//
//  NSString+UIImage.h
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (UIImage)

- (UIImage *)image;

// Since we always need a sqare image, we only request for the side
- (UIImage *)imageWithSide:(CGFloat)side;

@end

NS_ASSUME_NONNULL_END
