//
//  InfinitePickerView.m
//  WePlay
//
//  Created by Eugene Pogrebnoy on 10.12.14.
//  Copyright (c) 2014 Dynamic Systems Group Limited. All rights reserved.
//

#import "EPInfinitePickerColumn.h"

@interface EPInfinitePickerColumn ()

@property (strong, nonatomic) UIPanGestureRecognizer *scrollGesture;

@property (strong, nonatomic) NSMutableArray *orderedSubviews;

@property (nonatomic) CGFloat deltaY;

@property (weak, nonatomic) UIView *selectedView;
@property (strong, nonatomic) UIView *selectionView;

@end

@implementation EPInfinitePickerColumn

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self genericInit];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self genericInit];
    }
    return self;
}

-(void) genericInit
{
    self.scrollGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollGesture)];
    [self addGestureRecognizer:self.scrollGesture];
    self.orderedSubviews = [NSMutableArray array];
    self.clipsToBounds = YES;
    self.rowHeight = 40;
    self.deltaY = 0;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void) handleScrollGesture
{
    CGPoint translation = [self.scrollGesture translationInView:self];
    CGPoint velocity = [self.scrollGesture velocityInView:self];
    switch (self.scrollGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self.layer removeAllAnimations];
            break;
        case UIGestureRecognizerStateChanged:
            self.bounds = CGRectMake(self.bounds.origin.x, -translation.y, self.bounds.size.width, self.bounds.size.height);
            [self setNeedsLayout];
            break;
        case UIGestureRecognizerStateEnded:
            [self finishScrollGestureWithVelocity:-velocity.y];
            break;
            
        default:
            break;
    }
}

- (void) finishScrollGestureWithVelocity:(CGFloat) velocity
{
    self.selectedRow = [self subviewAtVerticalPosition:self.bounds.origin.y + self.bounds.size.height / 2].tag;
}

- (void) selectRow:(NSInteger)row
{
    CGFloat target = row * self.rowHeight + self.deltaY;
    
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.bounds = CGRectMake(self.bounds.origin.x, target, self.bounds.size.width, self.bounds.size.height);
                     } completion:^(BOOL finished) {
                         for (UIView *view in self.subviews) {
                             CGRect frame = view.frame;
                             frame.origin.y -= self.bounds.origin.y;
                             view.frame = frame;
                         }
                         self.deltaY -= self.bounds.origin.y;
                         self.bounds = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, self.bounds.size.height);
                         [self.scrollGesture setTranslation:CGPointZero inView:self];
                         [self setNeedsLayout];

                         _selectedRow = row;
                         [self.delegate infinitePickerColumn:self selectedRowAtIndex:self.selectedRow];
                     }
     ];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
        
    if (self.orderedSubviews.count == 0) {
        UIView *view = [self addSubviewAtTop];
        CGRect frame = view.frame;
        frame.origin.y = self.bounds.origin.y + self.bounds.size.height / 2 - frame.size.height / 2;
        view.frame = frame;
    }
    
    CGFloat min = ((UIView*)self.orderedSubviews[0]).frame.origin.y;
    CGFloat max = ((UIView*)self.orderedSubviews[self.orderedSubviews.count - 1]).frame.origin.y + ((UIView*)self.orderedSubviews[self.orderedSubviews.count - 1]).frame.size.height;
    while (min > self.bounds.origin.y) {
        UIView *view = [self addSubviewAtTop];
        min = view.frame.origin.y;
    }
    while (max < self.bounds.origin.y + self.bounds.size.height) {
        UIView *view = [self addSubviewAtBottom];
        max = view.frame.origin.y + view.frame.size.height;
    }
    while (self.orderedSubviews.count > 0 && ((UIView*)self.orderedSubviews[0]).frame.origin.y + ((UIView*)self.orderedSubviews[0]).frame.size.height < self.bounds.origin.y) {
        [((UIView*)self.orderedSubviews[0]) removeFromSuperview];
        [self.orderedSubviews removeObjectAtIndex:0];
    }
    while (self.orderedSubviews.count > 0 && ((UIView*)self.orderedSubviews[self.orderedSubviews.count - 1]).frame.origin.y > self.bounds.origin.y + self.bounds.size.height) {
        [((UIView*)self.orderedSubviews[self.orderedSubviews.count - 1]) removeFromSuperview];
        [self.orderedSubviews removeObjectAtIndex:self.orderedSubviews.count - 1];
    }
    
    UIView *selectedView = [self subviewAtVerticalPosition:self.bounds.origin.y + self.bounds.size.height / 2];
    if (selectedView != self.selectedView) {
        [self.selectionView removeFromSuperview];
        self.selectedView.hidden = NO;
        self.selectedView = selectedView;
        self.selectedView.hidden = YES;
        self.selectionView = [self.dataSource infinitePickerColumn:self viewForRowAtIndex:self.selectedView.tag selected:YES];
        self.selectionView.frame = self.selectedView.frame;
        [self addSubview:self.selectionView];
    }
}

- (UIView*) addSubviewAtTop
{
    CGFloat y = self.bounds.origin.y;
    NSInteger index = self.selectedRow;
    if (self.orderedSubviews.count > 0) {
        y = ((UIView*)self.orderedSubviews[0]).frame.origin.y;
        index = ((UIView*)self.orderedSubviews[0]).tag - 1;
    }
    UIView *view = [self.dataSource infinitePickerColumn:self viewForRowAtIndex:index selected:false];
    view.frame = CGRectMake(0, y - self.rowHeight, self.bounds.size.width, self.rowHeight);
    view.tag = index;
    [self addSubview:view];
    [self.orderedSubviews insertObject:view atIndex:0];
    return view;
}

- (UIView*) addSubviewAtBottom
{
    CGFloat y = self.bounds.origin.y;
    NSInteger index = self.selectedRow;
    if (self.orderedSubviews.count > 0) {
        CGRect frame = ((UIView*)self.orderedSubviews[self.orderedSubviews.count - 1]).frame;
        y = frame.origin.y + frame.size.height;
        index = ((UIView*)self.orderedSubviews[self.orderedSubviews.count - 1]).tag + 1;
    }
    UIView *view = [self.dataSource infinitePickerColumn:self viewForRowAtIndex:index selected:false];
    view.frame = CGRectMake(0, y, self.bounds.size.width, self.rowHeight);
    view.tag = index;
    [self addSubview:view];
    [self.orderedSubviews insertObject:view atIndex:self.orderedSubviews.count];
    return view;
}

- (UIView*) subviewAtVerticalPosition:(CGFloat)y
{
    int l = 0, r = self.orderedSubviews.count - 1;
    while (r - l > 1) {
        int c = (l + r) / 2;
        UIView *view = self.orderedSubviews[c];
        if (view.frame.origin.y > y)
            r = c;
        else
            l = c;
    }
    return self.orderedSubviews[l];
}

- (void)setSelectedRow:(NSInteger)selectedRow
{
    _selectedRow = selectedRow;
    [self selectRow:selectedRow];
}

- (void) reloadData
{
    [self.layer removeAllAnimations];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self.orderedSubviews removeAllObjects];
    self.bounds = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, self.bounds.size.height);
    self.deltaY = -self.rowHeight*self.selectedRow;
    [self setNeedsLayout];
}

@end
