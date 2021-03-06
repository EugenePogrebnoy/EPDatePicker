//
//  InfinitePickerView.h
//  WePlay
//
//  Created by Eugene Pogrebnoy on 10.12.14.
//  Copyright (c) 2014 Dynamic Systems Group Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPInfinitePickerColumn;

@protocol InfinitePickerColumnDataSource <NSObject>

- (UIView*) infinitePickerColumn:(EPInfinitePickerColumn*)pickerColumn viewForRowAtIndex: (NSInteger) index selected:(BOOL) selected;

@end

@protocol InfinitePickerColumnDelegate <NSObject>

@optional
- (void) infinitePickerColumn:(EPInfinitePickerColumn*)pickerColumn selectedRowAtIndex: (NSInteger) index;

@end

@interface EPInfinitePickerColumn : UIView

@property (nonatomic) CGFloat rowHeight;

@property (weak, nonatomic) id<InfinitePickerColumnDataSource> dataSource;
@property (weak, nonatomic) id<InfinitePickerColumnDelegate> delegate;

@property (nonatomic) NSInteger selectedRow;

- (void) reloadData;

@property (nonatomic) NSInteger minRow;
@property (nonatomic) NSInteger maxRow;

@property (nonatomic, readonly) BOOL isInAnimation;

@end