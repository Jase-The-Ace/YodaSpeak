//
//  YodaSpokenListAdapter.m
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import "YodaSpokenListAdapter.h"
#import "YodaSpokeCell.h"
#import "YodaSpoke.h"

@implementation YodaSpokenListAdapter

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YodaSpokeCell *streamCell = [self yodaCell:indexPath.row tableView:tableView];
    
    return streamCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 85.0f;
    return height;
}

- (YodaSpokeCell *)yodaCell:(NSInteger)row tableView:(UITableView *)tableView {
    YodaSpokeCell *yodaCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YodaSpokeCell class])];
    
    if (!yodaCell) {
        yodaCell = [[YodaSpokeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([YodaSpokeCell class])];
    }
    
    YodaSpoke *yodaSpoke = self.list[row];
    
    yodaCell.yodaText.text = yodaSpoke.yodaText;
    yodaCell.text.text = yodaSpoke.text;
    yodaCell.date.text = [yodaSpoke.date formattedDate:@"hh:mm, MMM dd yyyy"];
    
    return yodaCell;
}


@end
