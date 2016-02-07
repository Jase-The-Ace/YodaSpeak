//
//  YodaSpokenListAdapter.h
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YodaSpokenListAdapter : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *list;

@end
