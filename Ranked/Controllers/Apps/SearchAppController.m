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
#import "AppManager.h"

@interface SearchAppController () <UISearchResultsUpdating>

@property (nonatomic, weak) UISearchController *searchController;

@property (nonatomic, weak) NSURLSessionTask *searchTask;

@property (nonatomic, copy) NSIndexPath *selectedIndex;

@property (nonatomic, copy) NSArray <App *> *searchResults;

@end

@implementation SearchAppController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"controller.searchapp.title", nil);
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    [self setupTableView];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDone)];
    done.enabled = NO;
    done.accessibilityLabel = NSLocalizedString(@"controller.searchapp.done.label", @"a11y Done button label");
    done.accessibilityHint = NSLocalizedString(@"controller.searchapp.done.hint", @"a11y Done button hint");
    
    self.navigationItem.rightBarButtonItem = done;
    
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self.searchController.searchBar isFirstResponder]) {
        [self.searchController.searchBar resignFirstResponder];
    }
    
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
    App *obj = [self.searchResults objectAtIndex:indexPath.item];

    if (obj) {
        [cell configure:obj];
    }
    
#warning TODO: Implement App Icon image
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedIndex != nil) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndex];
        
        if (cell != nil) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    if (self.navigationItem.rightBarButtonItem.isEnabled == NO) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.selectedIndex = indexPath;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell != nil) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    __block NSString *text = nil;
    
    // dispatch after 2 seconds giving the user time to complete their search input
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), TunesManager.sharedManager.queue, ^{
        
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
        
        self.searchTask = [[TunesManager sharedManager] searchForApp:text success:^(NSArray <App *> * _Nonnull responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.searchResults = responseObject;
                
                self.selectedIndex = nil;
                
                [self.tableView reloadData];
                
            });
            
        } error:^(NSError * _Nonnull error) {
           
            if (error) {
                NSLog(@"Error searching for app: %@\n%@", text, error.localizedDescription);
            }
            
        }];
        
    });
    
}

#pragma mark - Actions

- (void)didTapDone {
    
    if (NSThread.isMainThread == NO) {
        [self performSelectorOnMainThread:@selector(didTapDone) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (self.selectedIndex == nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        return;
    }
    
    App *app = [self.searchResults objectAtIndex:self.selectedIndex.row];
    
    [[AppManager sharedManager] addApp:app];
    
    [self.navigationController popViewControllerAnimated:YES];
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
