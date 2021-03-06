//
// SYMTableViewBinding.m
//
// Copyright (c) 2015 Dan Hall
// Twitter: @_danielhall
// GitHub: https://github.com/daniel-hall
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "SYMTableViewBinding.h"
#import "UITableView+SymbiOSis.h"
#import "UIView+SymbiOSisPrivate.h"


@implementation SYMTableViewBinding

@dynamic value;
@dynamic views;
@synthesize sourceValue = _sourceValue;


-(void)awakeFromNib {
    // The below silliness exists because bindings have to subclass UIView in order to be added to prototype cells, but we don't want them visible
    self.frame = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.alpha = 0;

    [self setup];

    if (self.dataSource) {
        [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionInitial context:nil];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super setValue:self.dataSource.value];
    for (UITableView *view in self.views) {
        [self updateView:view];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSections];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rowHeights = [self.rowHeights componentsSeparatedByString:@","];
    if (indexPath.section < rowHeights.count) {
        NSString *rowHeight = rowHeights[indexPath.section];
        return rowHeight.floatValue;
    }

    return tableView.rowHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSArray *headerTitles = [self.headerTitles componentsSeparatedByString:@","];
    NSArray *headerHeights = [self.headerHeights componentsSeparatedByString:@","];
    if (section < self.headerViews.count) {
        UIView *headerView = self.headerViews[section];
        return headerView.frame.size.height;
    }
    else if (section < headerHeights.count) {
        NSString *headerHeight = headerHeights[section];
        return [headerHeight floatValue];
    }
    else if (section < headerTitles.count) {
        return tableView.sectionHeaderHeight;
    }
    else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSArray *footerTitles = [self.footerTitles componentsSeparatedByString:@","];
    NSArray *footerHeights = [self.footerHeights componentsSeparatedByString:@","];
    if (section < self.footerViews.count) {
        UIView *footerView = self.footerViews[section];
        return footerView.frame.size.height;
    }
    else if (section < footerHeights.count) {
        NSString *footerHeight = footerHeights[section];
        return [footerHeight floatValue];
    }
    else if (section < footerTitles.count) {
        return tableView.sectionFooterHeight;
    }
    else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arrayOfIdentifiers = [self.cellReuseIdentifiers componentsSeparatedByString:@","];
    // If there aren't identifiers provided for every section, just use the first one for all
    NSInteger section = indexPath.section < arrayOfIdentifiers.count ? indexPath.section : 0;
    return [tableView dequeueReusableCellWithIdentifier:arrayOfIdentifiers[section] andDataSourceIndexPath:indexPath];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < self.headerViews.count) {
        UIView *headerView = [self.headerViews[section] copy];
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, headerView.frame.size.height);
        [headerView layoutSubviews];
        return headerView;
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section < self.footerViews.count) {
        UIView *footerView = [self.footerViews[section] copy];
        footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, footerView.frame.size.height);
        [footerView layoutSubviews];
        return footerView;
    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *headerTitles = [self.headerTitles componentsSeparatedByString:@","];
    if (section < headerTitles.count) {
        return headerTitles[section];
    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSArray *footerTitles = [self.footerTitles componentsSeparatedByString:@","];
    if (section < footerTitles.count) {
        return footerTitles[section];
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id value = [self.dataSource valueForIndexPath:indexPath];
    for (SYMTableViewCellSelectionResponder *responder in self.cellSelectionResponders) {
        [responder tableView:tableView selectedCell:cell atIndexPath:indexPath withValue:value];
    }
    self.sourceValue = value;
}


- (void)updateView:(UITableView *)view {
    [view reloadData];
}

- (void)dealloc {
    [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
}


@end
