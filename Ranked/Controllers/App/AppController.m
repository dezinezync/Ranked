//
//  AppController.m
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppController.h"
#import "CountriesController.h"
#import "RankCell.h"

#import "macros.h"

static void *KVO_App_Countries = &KVO_App_Countries;

@interface AppController () {
    BOOL _shouldRefresh;
    
    BOOL _hasLoadedOnce;
}

@property (nonatomic, weak) App *app;
@property (nonatomic, strong) UITableViewDiffableDataSource *DS;

@end

@implementation AppController

- (instancetype)initWithApp:(App *)app {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        self.app = app;
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.app.name;
    
    [self setupTableView];
    
    UIBarButtonItem *countries = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didTapCountries)];
    countries.accessibilityValue = NSLocalizedString(@"controller.app.edit.title", @"a11y title for the Edit button");
    countries.accessibilityHint = NSLocalizedString(@"controller.app.edit.hint", @"a11y hint for the Edit button");
    
    self.navigationItem.rightBarButtonItem = countries;
    
    [self.app addObserver:self forKeyPath:propSel(countries) options:NSKeyValueObservingOptionNew context:KVO_App_Countries];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    if (self) {
        self->_shouldRefresh = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self->_hasLoadedOnce == NO) {
        self->_hasLoadedOnce = YES;
        
        [self getData];
    }
    else if (self->_shouldRefresh) {
        self->_shouldRefresh = NO;
        
        [self getData];
    }
    
}

- (void)dealloc {
    
    if (self.app != nil) {
        [self.app removeObserver:self forKeyPath:propSel(countries) context:KVO_App_Countries];
    }
    
}

#pragma mark - Setups

- (void)setupTableView {
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl sizeToFit];
    
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = refreshControl;
    
    [RankCell registerOnTableView:self.tableView];
    self.tableView.tableFooterView = [UIView new];
    
    self.DS = [[UITableViewDiffableDataSource alloc] initWithTableView:self.tableView cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, NSString *_Nonnull countryIdentifier) {
        
        RankCell *cell = [tableView dequeueReusableCellWithIdentifier:kRankCell forIndexPath:indexPath];
        
         Country *country = [[self.app.trackedCountries allObjects] objectAtIndex:indexPath.row];
        
        // Configure the cell...
        if (country) {
            [cell configure:country app:self.app];
        }
        
        return cell;
        
    }];
    
    [self setupData];
    
}

- (void)setupData {
    
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[@0]];
    [snapshot appendItemsWithIdentifiers:self.app.countries.objectEnumerator.allObjects];
    
    [self.DS applySnapshot:snapshot animatingDifferences:YES];
    
}

#pragma mark - Actions

- (void)didTapCountries {
    
    CountriesController *controller = [[CountriesController alloc] initWithApp:self.app];
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)refreshData:(UIRefreshControl *)sender {
    
    // regardless of what happens, dismiss the refresh control after 5s
    if (sender && [sender isKindOfClass:UIRefreshControl.class]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (sender.isRefreshing) {
                [sender endRefreshing];
            }
        });
        
    }
    
    [self getData];
    
}

- (void)getData {
 
    [TunesManager.sharedManager ranksForApp:self.app progress:^(NSString * _Nonnull shortCode, NSNumber * _Nonnull rank) {
        
        // As a report becomes available, this block is called
        NSUInteger index = [self.app.countries indexOfObject:shortCode];
        if (index == NSNotFound) {
            return;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        RankCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        NSNumber *old = self.app.rankings[shortCode];
        
        self.app.oldRankings[shortCode] = old;
        self.app.rankings[shortCode] = rank;
        
        [cell updateRank:rank old:old];
        
    } success:^(NSDictionary<NSString *,NSNumber *> * _Nonnull responseObjects) {
        
        // Once all reports are available, this block is called
        
        // this ensures that our visible cells get updated if the result was updated when the row wasn't visible.
        NSDiffableDataSourceSnapshot *snapshot = self.DS.snapshot;
        
        NSMutableArray *reloadIdentifiers = [NSMutableArray arrayWithCapacity:self.tableView.indexPathsForVisibleRows.count];
        
        for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
            id object = [self.DS itemIdentifierForIndexPath:indexPath];
            
            if (object) {
                [reloadIdentifiers addObject:object];
            }
            
        }
        
        [snapshot reloadItemsWithIdentifiers:reloadIdentifiers];
        
        [self.DS applySnapshot:snapshot animatingDifferences:YES];
        
        [AppManager.sharedManager save];
        
    } error:^(NSError * _Nonnull error) {
        
        // This block can be called multiple times so we never present an Alert dialog from here.
        
        NSLog(@"Error: %@", error);
        
    }];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:propSel(countries)]
        && object == self.app
        && context == KVO_App_Countries) {
        
        [self setupData];
        [self getData];
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

@end
