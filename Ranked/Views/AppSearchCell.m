//
//  AppSearchCell.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppSearchCell.h"

NSString *const kAppSearchCell = @"com.dezinezync.ranked.cell.appsearch";

@implementation AppSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.appicon.bounds cornerRadius:9.428571429f];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.appicon.bounds;
    maskLayer.path = path.CGPath;
    
    self.appicon.layer.mask = maskLayer;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.appTitle.text = nil;
    self.developerName.text = nil;
    self.appicon.image = nil;
    self.imageDownloadTask = nil;
    
}

- (void)configure:(App *)app {
    
    self.appTitle.text = app.name;
    self.developerName.text = app.developer;
    
    NSURL *url = app.artwork[@"100"];
    
    dispatch_async(TunesManager.sharedManager.queue, ^{
        self.imageDownloadTask = [TunesManager.sharedManager imageForURL:url size:CGSizeMake(44.f, 44.f) success:^(UIImage * _Nullable image) {
            
            self.appicon.image = image;
            
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
