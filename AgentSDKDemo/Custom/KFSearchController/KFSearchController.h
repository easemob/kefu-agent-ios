//
//  KFSearchController.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2020/6/2.
//  Copyright © 2020 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFSearchController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong, nullable) NSString *searchKeyword;


@property (copy) UITableViewCell * (^cellForRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) void (^didSelectRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) void (^didDeselectRowAtIndexPathCompletion)(UITableView *tableView, NSIndexPath *indexPath);
@property (copy) NSInteger (^numberOfSectionsInTableViewCompletion)(UITableView *tableView);
@property (copy) NSInteger (^numberOfRowsInSectionCompletion)(UITableView *tableView, NSInteger section);


@end

@protocol HDSearchControllerDelegate <NSObject>

@optional

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar;

- (void)searchBarCancelButtonAction:(nullable UISearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

- (void)searchTextDidChangeWithString:(NSString *)aString;

@end


NS_ASSUME_NONNULL_END
