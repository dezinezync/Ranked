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
@property (nonatomic, strong) UICollectionViewDiffableDataSource *DS;

@end

@implementation AppsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.title = NSLocalizedString(@"controller.apps.title", nil);
    self.apps = [AppManager sharedManager].apps;
    
    // Uncomment the following line to preserve selection between presentations
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Do any additional setup after loading the view.
    self.collectionView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAdd)];
    add.accessibilityValue = NSLocalizedString(@"controller.apps.new.title", @"a11y title for the Add button");
    add.accessibilityHint = NSLocalizedString(@"controller.apps.new.hint", @"a11y hint for the Add button");
    
    self.navigationItem.rightBarButtonItem = add;
    
    [self setupCollectionView];
    
}

#pragma mark - Setups

- (void)setupCollectionView {
    
    self.DS = [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, App * _Nonnull app) {
       
        AppCell *cell = (AppCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kAppCell forIndexPath:indexPath];
        
        // Configure the cell
        if (app != nil) {
            [cell configure:app];
        }
        
        return cell;
        
    }];
    
    [AppCell registerOnCollectionView:self.collectionView];
    
    [[AppManager sharedManager] addObserver:self forKeyPath:propSel(apps) options:NSKeyValueObservingOptionNew context:KVO_Apps];
    
    [self setupData];
    
}

- (void)setupData {
    
    NSDiffableDataSourceSnapshot *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[@0]];
    [snapshot appendItemsWithIdentifiers:self.apps];
    
    [self.DS applySnapshot:snapshot animatingDifferences:YES];
    
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    App *app = [self.apps objectAtIndex:indexPath.item];
    
    if (app) {
        AppController *controller = [[AppController alloc] initWithApp:app];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    
    UIContextMenuConfiguration *config = [UIContextMenuConfiguration configurationWithIdentifier:@"cell.action" previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
       
        UIAction * delete = [UIAction actionWithTitle:@"Delete" image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            
            App *app = [self.DS itemIdentifierForIndexPath:indexPath];
            
            [AppManager.sharedManager removeApp:app];
            
        }];
        
        delete.attributes = UIMenuElementAttributesDestructive;
        
        return [UIMenu menuWithTitle:@"App Actions" children:@[delete]];
        
    }];
    
    return config;
    
}

#pragma mark - Accessors

+ (UICollectionViewCompositionalLayout *)layout {
    
    NSCollectionLayoutSize * itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.3f] heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.f]];
    
    NSCollectionLayoutItem * item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
    
    NSCollectionLayoutSize * groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f] heightDimension:[NSCollectionLayoutDimension estimatedDimension:160.f]];
    
    NSCollectionLayoutGroup * group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:3];
    group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:1.f];
    
    NSCollectionLayoutSection * section = [NSCollectionLayoutSection sectionWithGroup:group];
    section.interGroupSpacing = 1.f;
    
    UICollectionViewCompositionalLayout * layout = [[UICollectionViewCompositionalLayout alloc] initWithSection:section];
    
    return layout;
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == KVO_Apps && [keyPath isEqualToString:propSel(apps)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.apps = [AppManager sharedManager].apps;
            [self setupData];
        });
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

@end
