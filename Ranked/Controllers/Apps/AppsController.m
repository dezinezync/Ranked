//
//  AppsController.m
//  Ranked
//
//  Created by Nikhil Nigade on 06/10/18.
//  Copyright © 2018 Nikhil Nigade. All rights reserved.
//

#import "AppsController+Actions.h"
#import "AppCell.h"

#import "AppManager.h"
#import "macros.h"
#import "AppController.h"

static void *KVO_Apps = &KVO_Apps;

@interface AppsController ()

@property (nonatomic, weak) NSArray <App *> *apps;

@end

@implementation AppsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"controller.apps.title", nil);
    self.apps = [AppManager sharedManager].apps;
    
    // Uncomment the following line to preserve selection between presentations
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(AppCell.class) bundle:nil] forCellWithReuseIdentifier:kAppCell];
    
    // Do any additional setup after loading the view.
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAdd)];
    add.accessibilityValue = NSLocalizedString(@"controller.apps.new.title", @"a11y title for the Add button");
    add.accessibilityHint = NSLocalizedString(@"controller.apps.new.hint", @"a11y hint for the Add button");
    
    self.navigationItem.rightBarButtonItem = add;
    
    [self setupLayout];
    
    [[AppManager sharedManager] addObserver:self forKeyPath:propSel(apps) options:NSKeyValueObservingOptionNew context:KVO_Apps];
    
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.apps.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AppCell *cell = (AppCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kAppCell forIndexPath:indexPath];
    
    // Configure the cell
    App *app = [self.apps objectAtIndex:indexPath.item];
    
    if (app != nil) {
        cell.appTitle.text = app.name;
        cell.category.text = app.genreName;
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    App *app = [self.apps objectAtIndex:indexPath.item];
    
    if (app) {
        AppController *controller = [[AppController alloc] initWithApp:app];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

#pragma mark -

- (void)setupLayout {
 
    // this logic is only applicable for iPhones at the moment.
#warning TODO: Implement Size Classes based logic for setting up the layout
    
    [self.collectionView layoutIfNeeded];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self.collectionView collectionViewLayout];
    
    CGFloat width = MIN(self.collectionView.bounds.size.width, self.collectionView.contentSize.width);
    CGFloat columnWidth = floor((width - 2.f) / 3.f);
    
    [layout setItemSize:CGSizeMake(columnWidth, columnWidth + (columnWidth * 0.2f))];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == KVO_Apps && [keyPath isEqualToString:propSel(apps)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.apps = [AppManager sharedManager].apps;
            [self.collectionView reloadData];
        });
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

@end
