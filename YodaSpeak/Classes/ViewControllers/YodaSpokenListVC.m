//
//  YodaSpokenListVC.m
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import "YodaSpokenListVC.h"
#import "YodaSpokenListAdapter.h"
#import "YodaSpoke.h"

@interface YodaSpokenListVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *list;

@property (nonatomic, strong) YodaSpokenListAdapter *listAdapter;

@end

@implementation YodaSpokenListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Yoda Spoken History";
    
    [self populateLists];
    self.listAdapter = [[YodaSpokenListAdapter alloc] init];
    self.tableView.delegate = self.listAdapter;
    self.tableView.dataSource = self.listAdapter;
    self.listAdapter.tableView = self.tableView;
    self.listAdapter.list = self.list;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)populateLists {
    self.list = [[YodaSpoke all] mutableCopy];
    self.list = [self sortByObjectDate:self.list];
}

- (NSMutableArray *)sortByObjectDate:(NSMutableArray *)array {
    return [[array sortedArrayUsingComparator:^NSComparisonResult(YodaSpoke *first, YodaSpoke *second) {
        
        if ([first.date isBeforeDate:second.date]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([first.date isAfterDate:second.date]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }] mutableCopy];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
