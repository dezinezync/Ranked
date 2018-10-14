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

- (void)configure:(Country *)country {
    self.flagView.image = country.flagImage;
    self.countryLabel.text = country.name;
    self.rankLabel.text = @"0";
    
    self.changeLabel.text = @"0";
    self.changeLabel.textColor = UIColor.lightGrayColor;
}

@end
