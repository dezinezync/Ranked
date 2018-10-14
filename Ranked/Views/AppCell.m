//
//  AppCell.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppCell.h"

NSString *const kAppCell = @"com.dezinezync.ranked.cell.app";

@implementation AppCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [self.tintColor colorWithAlphaComponent:0.3f];
    self.selectedBackgroundView.alpha = 0;
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    self.selectedBackgroundView.alpha = selected ? 1.f : 0.f;
    
}

@end
