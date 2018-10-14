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

@interface AppController () {
    BOOL _shouldRefresh;
}

@property (nonatomic, weak) App *app;

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl sizeToFit];
    
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = refreshControl;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(RankCell.class) bundle:nil] forCellReuseIdentifier:kRankCell];
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *countries = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didTapCountries)];
    countries.accessibilityValue = NSLocalizedString(@"controller.app.edit.title", @"a11y title for the Edit button");
    countries.accessibilityHint = NSLocalizedString(@"controller.app.edit.hint", @"a11y hint for the Edit button");
    
    self.navigationItem.rightBarButtonItem = countries;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    if (self) {
        self->_shouldRefresh = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self->_shouldRefresh) {
        self->_shouldRefresh = NO;
        
        [self getData];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.app.countries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankCell *cell = [tableView dequeueReusableCellWithIdentifier:kRankCell forIndexPath:indexPath];
    
    // Configure the cell...
    Country *country = [[self.app.trackedCountries allObjects] objectAtIndex:indexPath.row];
    if (country) {
        [cell configure:country app:self.app];
    }
    
    return cell;
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
    
}

@end