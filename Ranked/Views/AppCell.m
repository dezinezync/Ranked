//
//  AppCell.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppCell.h"

NSString *const kAppCell = @"com.ranked.cell.app";

@implementation AppCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds cornerRadius:9.428571429f];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.imageView.bounds;
    maskLayer.path = path.CGPath;
    
    self.imageView.layer.mask = maskLayer;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [self.tintColor colorWithAlphaComponent:0.3f];
    self.selectedBackgroundView.alpha = 0;
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    self.selectedBackgroundView.alpha = selected ? 1.f : 0.f;
    
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.appTitle.text = nil;
    self.category.text = nil;
    self.imageView.image = nil;
    self.imageDownloadTask = nil;
    
}

- (void)configure:(App *)app {
    
    self.appTitle.text = app.name;
    self.category.text = app.genreName;
    
    NSURL *url = app.artwork[@"100"];
    
    dispatch_async(TunesManager.sharedManager.queue, ^{
        self.imageDownloadTask = [TunesManager.sharedManager imageForURL:url size:CGSizeMake(44.f, 44.f) success:^(UIImage * _Nullable image) {
            
            self.imageView.image = image;
            
        } error:^(NSError * _Nonnull error) {
            
            NSLog(@"Download error for:%@\n%@", url, error);
            
        }];
    });
    
}

- (void)setImageDownloadTask:(NSURLSessionTask *)imageDownloadTask {
    
    if (_imageDownloadTask) {
        [_imageDownloadTask cancel];
    }
    
    _imageDownloadTask = imageDownloadTask;
    
}

@end
