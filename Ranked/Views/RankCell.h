//
//  RankCell.h
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "App.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kRankCell;

@interface RankCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *flagView;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;

- (void)configure:(Country *)country app:(App *)app;

- (void)updateRank:(NSNumber *)newRank old:(NSNumber *)oldRank;

@end

NS_ASSUME_NONNULL_END
