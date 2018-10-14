//
//  NSString+UIImage.m
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "NSString+UIImage.h"

@implementation NSString (UIImage)

- (UIImage *)image {
    
    return [self imageWithSide:32.f];
    
}

- (UIImage *)imageWithSide:(CGFloat)side {
    
    side = MAX(side, 16.f);
    
    CGSize size = CGSizeMake(side, side);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [UIColor.clearColor set];
    
    CGRect rect = CGRectMake(0, 0, side, side);
    
    UIRectFill(rect);
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    [self drawInRect:rect withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:(side - 8.f)],
                                           NSParagraphStyleAttributeName: paragraph
                                           }];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

@end
