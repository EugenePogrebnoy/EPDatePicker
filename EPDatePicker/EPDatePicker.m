//
//  EPDatePicker.m
//  WePlay
//
//  Created by Eugene Pogrebnoy on 10.12.14.
//  Copyright (c) 2014 Dynamic Systems Group Limited. All rights reserved.
//

#import "EPDatePicker.h"
#import "EPInfinitePickerColumn.h"

@interface EPDatePicker () <InfinitePickerColumnDelegate, InfinitePickerColumnDataSource>

@property (strong, nonatomic) EPInfinitePickerColumn *yearPicker;

@end

@implementation EPDatePicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self genericInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self genericInit];
    }
    return self;
}

- (void) genericInit
{
    self.yearPicker = [[EPInfinitePickerColumn alloc] initWithFrame:self.bounds];
    self.yearPicker.delegate = self;
    self.yearPicker.dataSource = self;
    [self addSubview:self.yearPicker];
}

- (void)infinitePickerColumn:(EPInfinitePickerColumn *)pickerColumn selectedRowAtIndex:(NSInteger)index
{
    CLS_LOG(@"selected %ld", (long)index);
}

- (UIView *)infinitePickerColumn:(EPInfinitePickerColumn *)pickerColumn viewForRowAtIndex:(NSInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [NSString stringWithFormat:@"%ld", (long) index];
    return label;
}

@end
