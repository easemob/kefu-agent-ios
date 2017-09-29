//
//  HSearchResultsViewController.h
//  EMCSApp
//
//  Created by afanda on 8/16/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSearchResultsViewController : UIViewController

@property(nonatomic,strong) NSMutableArray *resultsSource;

@property(nonatomic,strong) UITableView *resultsTableView;

@end
