//
//  SearchAppController.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "SearchAppController.h"
#import "AppSearchCell.h"

#import "TunesManager.h"

@interface SearchAppController () <UISearchResultsUpdating>

@property (nonatomic, weak) UISearchController *searchController;

@property (nonatomic, weak) NSURLSessionTask *searchTask;

@end

@implementation SearchAppController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"controller.searchapp.title", nil);
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    [self setupTableView];
}

- (BOOL)definesPresentationContext {
    return YES;
}

#pragma mark -

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.searchController.searchBar becomeFirstResponder];
    });
}

#pragma mark - <UITableViewDatasource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults != nil ? self.searchResults.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppSearchCell *cell = (AppSearchCell *)[tableView dequeueReusableCellWithIdentifier:kAppSearchCell forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *obj = [self.searchResults objectAtIndex:indexPath.item];
    
#warning Convert dictionary to NSObject so it's easier to store and access
    cell.appTitle.text = [obj valueForKey:@"name"];
    cell.developerName.text = [obj valueForKey:@"developer"];
    
    return cell;
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    __block NSString *text = nil;
    
    // dispatch after 2 seconds giving the user time to complete their search input
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // if there is an existing search task, cancel it
        if (self.searchTask != nil) {
            [self.searchTask cancel];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            text = searchController.searchBar.text;
        });
        
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            return;
        }
        
        self.searchTask = [[TunesManager sharedManager] searchForApp:text success:^(NSDictionary * _Nonnull responseObject) {
            
            /**
             {
                resultCount: Number,
                results: Array <Object>
             }
             */
            
            if ([[responseObject valueForKey:@"resultCount"] integerValue] == 0) {
                // handle empty state.
                return;
            }
            
            // we have results
            NSArray <NSDictionary *> * results = [responseObject objectForKey:@"results"];
            
            // we're only interested in a few keys from the results
            NSMutableArray *required = [NSMutableArray arrayWithCapacity:results.count];
            
            for (NSDictionary *obj in results) {
                
                NSDictionary *requisiteInfo = @{@"artistId": obj[@"artistId"],
                                                @"developer": obj[@"sellerName"],
                                                @"artwork": @[obj[@"artworkUrl100"], obj[@"artworkUrl512"], obj[@"artworkUrl60"]],
                                                @"genre": obj[@"primaryGenreId"],
                                                @"genreName": obj[@"primaryGenreName"],
                                                @"name": obj[@"trackName"],
                                                @"url": obj[@"trackViewUrl"]
                                                };
                
                [required addObject:requisiteInfo];
                
            }
            
            results = required.copy;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.searchResults = results;
                
                [self.tableView reloadData];
                
            });
            
        } error:^(NSError * _Nonnull error) {
           
            if (error) {
                NSLog(@"Error searching for app: %@\n%@", text, error.localizedDescription);
            }
            
        }];
        
    });
    
}

#pragma mark -

- (void)setupTableView {
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchBar.placeholder = NSLocalizedString(@"com.controller.searchapp.search.title", @"Search Bar Placeholder");
    searchController.searchResultsUpdater = self;
    searchController.hidesNavigationBarDuringPresentation = NO;
    searchController.dimsBackgroundDuringPresentation = NO;
    
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.navigationItem.searchController = searchController;
    self.searchController = searchController;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(AppSearchCell.class) bundle:nil] forCellReuseIdentifier:kAppSearchCell];
    
}

@end
