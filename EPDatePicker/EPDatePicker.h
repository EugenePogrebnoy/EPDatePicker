//
//  EPDatePicker.h
//  WePlay
//
//  Created by Eugene Pogrebnoy on 10.12.14.
//  Copyright (c) 2014 Dynamic Systems Group Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface EPDatePicker : UIView

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSTimeZone *timeZone;
@property (copy, nonatomic) NSCalendar *calendar;

@property (copy, nonatomic) NSDate *minimumDate;
@property (copy, nonatomic) NSDate *maximumDate;

@property (copy, nonatomic) UIFont *textFont;
@property (copy, nonatomic) UIFont *selectedTextFont;
@property (copy, nonatomic) UIFont *disabledTextFont;

@property (copy, nonatomic) IBInspectable UIColor *textColor;
@property (copy, nonatomic) IBInspectable UIColor *selectedTextColor;
@property (copy, nonatomic) IBInspectable UIColor *disabledTextColor;

@end
