//
//  CountriesController.m
//  Ranked
//
//  Created by Nikhil Nigade on 14/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "CountriesController.h"

NSString *const kCountryCell = @"com.ranked.cells.country";

@interface CountriesController ()

@property (nonatomic, weak) App *app;

@end

@implementation CountriesController

- (instancetype)initWithApp:(App *)app {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.app = app;
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"controller.countries.title", nil);
    
    self.tableView.allowsMultipleSelection = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDone:)];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:kCountryCell];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self _preselectCountries:animated];
    
}

- (void)_preselectCountries:(BOOL)animated {
    NSOrderedSet <Country *> *countries = TunesManager.sharedManager.countries;
    
    [self.app.trackedCountries.allObjects enumerateObjectsUsingBlock:^(Country * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSUInteger index = [countries indexOfObject:obj];
        
        if (index == NSNotFound) {
            return;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TunesManager.sharedManager countries].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCountryCell forIndexPath:indexPath];
    
    // Configure the cell...
    Country *country = [TunesManager.sharedManager.countries objectAtIndex:indexPath.row];
    
    if (country != nil) {
        cell.textLabel.text = country.name;
        cell.imageView.image = country.flagImage;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return cell;
}

#pragma mark - <UITableViewDataSourcePrefetching>

#pragma mark - Actions

- (void)didTapDone:(UIBarButtonItem *)sender {
    
    sender.enabled = NO;
    
    NSArray <NSIndexPath *> *selectedIndexPaths =  [self.tableView indexPathsForSelectedRows];
    
    NSMutableArray <NSString *> *selectedCountries = [NSMutableArray arrayWithCapacity:selectedIndexPaths.count];
    
    NSOrderedSet *countries = TunesManager.sharedManager.countries;
    
    [selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        Country *country = [countries objectAtIndex:obj.row];
        [selectedCountries addObject:country.shortCode];
        
    }];
    
    self.app.countries = selectedCountries.copy;
    
    [AppManager.sharedManager save];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
