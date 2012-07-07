//
//  FSVerticalTabBarController.m
//  iOS-Platform
//
//  Created by Błażej Biesiada on 4/6/12.
//  Copyright (c) 2012 Future Simple. All rights reserved.
//

#import "FSVerticalTabBarController.h"


#define DEFAULT_TAB_BAR_HEIGHT 100.0


@interface FSVerticalTabBarController ()
- (void)_performInitialization;
@end


@implementation FSVerticalTabBarController


@synthesize delegate = _delegate;
@synthesize tabBar = _tabBar;
@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize tabBarWidth = _tabBarWidth;
@synthesize infoView = _infoView;
@synthesize infoLabel = _infoLabel;


- (FSVerticalTabBar *)tabBar
{
    if (_tabBar == nil)
    {
        _tabBar = [[FSVerticalTabBar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
        _tabBar.delegate = self;
    }
    return _tabBar;
}


- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = [viewControllers copy];
    
    // create tab bar items
    if (self.tabBar != nil)
    {
        NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
        for (UIViewController *vc in self.viewControllers)
        {
            [tabBarItems addObject:vc.tabBarItem];
        }
        self.tabBar.items = tabBarItems;
    }
    
    // select first VC from the new array
    // sets the value for the first time as -1 for the viewController to load itself properly
    _selectedIndex = -1;
    
    self.selectedIndex = [viewControllers count] > 0 ? 0 : -1;
}


- (UIViewController *)selectedViewController
{
    if (self.selectedIndex < [self.viewControllers count])
    {
        return [self.viewControllers objectAtIndex:self.selectedIndex];
    }
    return nil;
}


- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    self.selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex != _selectedIndex && selectedIndex < [self.viewControllers count])
    {
        // add new view controller to hierarchy
        UIViewController *selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
        [self addChildViewController:selectedViewController];
        selectedViewController.view.frame = CGRectMake(self.tabBarWidth,
                                                       0,
                                                       self.view.bounds.size.width-self.tabBarWidth,
                                                       self.view.bounds.size.height);
        selectedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:selectedViewController.view];
        
        // remove previously selected view controller (if any)
        if ((int)_selectedIndex >= 0 && (int)_selectedIndex < [[self viewControllers] count]) {
            UIViewController *previousViewController = [self.viewControllers objectAtIndex:_selectedIndex];
            [previousViewController.view removeFromSuperview];
            [previousViewController removeFromParentViewController];
        }

        // set new selected index
        _selectedIndex = selectedIndex;
        
        // update tab bar
        if (selectedIndex < [self.tabBar.items count])
        {
            self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:selectedIndex];
        }
        
        // inform delegate
        if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
        {
            [self.delegate tabBarController:self didSelectViewController:selectedViewController];
        }
    }
}


- (void)_performInitialization
{
    self.tabBarWidth = DEFAULT_TAB_BAR_HEIGHT;
    self.selectedIndex = INT_MAX;
}


#pragma mark -
#pragma mark UIViewController
- (id)init
{
    if ((self = [super init]))
    {
        [self _performInitialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self _performInitialization];
    }
    return self;
}

- (void)customizeInfoLabel
{
    self.infoLabel.layer.cornerRadius = 5.0f;
    self.infoLabel.text = @"Info Label";
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.infoLabel.textAlignment = UITextAlignmentCenter;
}

- (void)loadView
{
    UIView *layoutContainerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    layoutContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    layoutContainerView.autoresizesSubviews = YES;
    
    // create the job number bar
    self.infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tabBarWidth, 44)];
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 8, self.tabBarWidth - 12, 28)];
    [self.infoView addSubview:self.infoLabel];
    [self customizeInfoLabel];
    
    // create tab bar
    self.tabBar.frame = CGRectMake(0, 44, self.tabBarWidth, layoutContainerView.bounds.size.height);
    [layoutContainerView addSubview:self.infoView];
    [layoutContainerView addSubview:self.tabBar];
    
    // return a ready view
    self.view = layoutContainerView;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIViewController *selectedViewController = self.selectedViewController;
    if (selectedViewController != nil)
    {
        return [selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return YES;
}


#pragma mark -
#pragma mark FSVerticalTabBarController
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    self.viewControllers = viewControllers;
}


#pragma mark -
#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedIndex:indexPath.row];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result;
    
    if ([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        UIViewController *newController = [self.viewControllers objectAtIndex:indexPath.row];
        result = [self.delegate tabBarController:self shouldSelectViewController:newController];
    }
    
    if (result) {
        return indexPath;
    }
    else {
        return tableView.indexPathForSelectedRow;
    }
}


@end
