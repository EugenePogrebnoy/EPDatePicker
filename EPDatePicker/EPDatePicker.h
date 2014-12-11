//
//  EPDatePicker.h
//  WePlay
//
//  Created by Eugene Pogrebnoy on 10.12.14.
//  Copyright (c) 2014 Dynamic Systems Group Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPDatePicker : UIView

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSTimeZone *timezone;

@end
