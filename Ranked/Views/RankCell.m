//
//  RankCell.m
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "RankCell.h"

NSString *const kRankCell = @"com.ranked.cell.rank";

@implementation RankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIFont *monospaced = [UIFont monospacedDigitSystemFontOfSize:17.f weight:UIFontWeightSemibold];
    UIFont *scaled = [[[UIFontMetrics alloc] initForTextStyle:UIFontTextStyleBody] scaledFontForFont:monospaced];
    
    self.changeLabel.font = scaled;
    self.rankLabel.font = scaled;
    
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    self.flagView.image = nil;
    self.countryLabel.text = nil;
    self.rankLabel.text = nil;
    self.changeLabel.text = nil;
}

- (void)configure:(Country *)country app:(nonnull App *)app {
    self.flagView.image = country.flagImage;
    self.countryLabel.text = country.name;
    
    NSNumber *current = (app.rankings[country.shortCode] ?: @0);
    NSNumber *old = (app.oldRankings[country.shortCode] ?: @0);
    
    self.rankLabel.text = [current stringValue];
    
    NSInteger change = current.integerValue - old.integerValue;
    
    self.changeLabel.text = [@(change) stringValue];
    
    if (change == 0) {
        self.changeLabel.textColor = UIColor.lightGrayColor;
    }
    else if (change > 0) {
        self.changeLabel.textColor = UIColor.greenColor;
    }
    else {
        self.changeLabel.textColor = UIColor.redColor;
    }
    
    
}

@end
