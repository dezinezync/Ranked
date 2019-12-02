//
//  AppCell.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TunesManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kAppCell;

@interface AppCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *appTitle;
@property (weak, nonatomic) IBOutlet UILabel *category;

@property (weak, nonatomic) NSURLSessionTask *imageDownloadTask;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

+ (void)registerOnCollectionView:(UICollectionView *)collectionView;

- (void)configure:(App *)app;

@end

NS_ASSUME_NONNULL_END
