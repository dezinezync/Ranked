//
//  AppsController+Actions.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppsController+Actions.h"
#import "SearchAppController.h"

@implementation AppsController (Actions)

- (void)didTapAdd {
    
    SearchAppController *controller = [[SearchAppController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
