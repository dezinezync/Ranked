//
//  SearchAppController.h
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchAppController : UITableViewController

@property (nonatomic, copy) NSArray <NSDictionary *> *searchResults;

@end

NS_ASSUME_NONNULL_END
