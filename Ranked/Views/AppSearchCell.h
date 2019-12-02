//
//  AppSearchCell.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TunesManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kAppSearchCell;

@interface AppSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *appicon;
@property (weak, nonatomic) IBOutlet UILabel *appTitle;
@property (weak, nonatomic) IBOutlet UILabel *developerName;

@property (weak, nonatomic) NSURLSessionTask *imageDownloadTask;

+ (void)registerOnTableView:(UITableView *)tableView;

- (void)configure:(App *)app;

@end

NS_ASSUME_NONNULL_END
