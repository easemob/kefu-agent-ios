//
//  UIViewController+KFSearch.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2020/6/2.
//  Copyright © 2020 环信. All rights reserved.
//

#import "UIViewController+KFSearch.h"


static const void *SearchButtonKey = &SearchButtonKey;
static const void *ResultControllerKey = &ResultControllerKey;
static const void *ResultNavigationControllerKey = &ResultNavigationControllerKey;

@interface UIViewController () <UISearchBarDelegate>

@end

@implementation UIViewController (KFSearch)

@dynamic searchButton;
@dynamic resultController;
@dynamic resultNavigationController;

#pragma mark - getter & setter

- (UIButton *)searchButton
{
    return objc_getAssociatedObject(self, SearchButtonKey);
}

- (void)setSearchButton:(UIButton *)searchButton
{
    objc_setAssociatedObject(self, SearchButtonKey, searchButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KFSearchController *)resultController
{
    return objc_getAssociatedObject(self, ResultControllerKey);
}

- (void)setResultController:(KFSearchController *)resultController
{
    objc_setAssociatedObject(self, ResultControllerKey, resultController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationController *)resultNavigationController
{
    return objc_getAssociatedObject(self, ResultNavigationControllerKey);
}

- (void)setResultNavigationController:(KFSearchController *)resultNavigationController
{
    objc_setAssociatedObject(self, ResultNavigationControllerKey, resultNavigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - enable

- (void)enableSearchController
{
    self.definesPresentationContext = YES;
    
    if (self.searchButton == nil) {
        self.searchButton = [[UIButton alloc] init];
        self.searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.searchButton.backgroundColor = UIColor.grayColor;
        self.searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
        self.searchButton.layer.cornerRadius = 8;
        self.searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        self.searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
        [self.searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        [self.searchButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.searchButton setImage:[UIImage imageNamed:@"search_gray"] forState:UIControlStateNormal];
        [self.searchButton addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];

    }
    
    if (self.resultNavigationController == nil) {
        self.resultController = [[KFSearchController alloc] init];
        self.resultController.searchBar.delegate = self;
        
        self.resultNavigationController = [[UINavigationController alloc] initWithRootViewController:self.resultController];
        [self.resultNavigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navBarBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forBarMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - disable

- (void)disableSearchController
{
    self.resultController.searchBar.delegate = nil;
    [self.searchButton removeFromSuperview];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if ([self conformsToProtocol:@protocol(HDSearchControllerDelegate)]
        && [self respondsToSelector:@selector(searchBarWillBeginEditing:)]) {
        [self performSelector:@selector(searchBarWillBeginEditing:)
                   withObject:searchBar];
    }
    
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        if ([self conformsToProtocol:@protocol(HDSearchControllerDelegate)]
            && [self respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
            [self performSelector:@selector(searchBarSearchButtonClicked:)
                       withObject:searchBar];
        }
        return NO;
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self conformsToProtocol:@protocol(HDSearchControllerDelegate)]
        && [self respondsToSelector:@selector(searchTextDidChangeWithString:)]) {
        [self performSelector:@selector(searchTextDidChangeWithString:)
                   withObject:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
    
    if ([self conformsToProtocol:@protocol(HDSearchControllerDelegate)]
        && [self respondsToSelector:@selector(searchBarCancelButtonAction:)]) {
        [self performSelector:@selector(searchBarCancelButtonAction:)
                   withObject:searchBar];
    }
}

#pragma mark - Action

- (void)searchButtonAction
{
    [self.resultController.searchBar becomeFirstResponder];
    self.resultController.searchBar.showsCancelButton = YES;
//    self.resultNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.resultNavigationController animated:YES completion:nil];
}

#pragma mark - public

- (void)cancelSearch
{
    self.resultController.searchBar.text = @"";
    [self.resultController.searchBar resignFirstResponder];
    self.resultController.searchBar.showsCancelButton = NO;
    [self.resultController dismissViewControllerAnimated:YES completion:nil];
}

@end
