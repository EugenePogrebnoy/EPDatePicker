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

@property (strong, nonatomic) EPInfinitePickerColumn *dayPicker;
@property (strong, nonatomic) EPInfinitePickerColumn *monthPicker;
@property (strong, nonatomic) EPInfinitePickerColumn *yearPicker;

@property (copy, nonatomic) NSDate *referenceDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSDateComponents *maxComponents;
@property (strong, nonatomic) NSDateComponents *minComponents;
@property (strong, nonatomic) NSDateComponents *components;

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
    self.date = [NSDate date];
    self.referenceDate = self.date;
    self.calendar = [NSCalendar currentCalendar];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.timezone = [NSTimeZone localTimeZone];
    
    CGFloat day_month_pos = 0.3 * self.bounds.size.width;
    CGFloat month_year_pos = 0.7 * self.bounds.size.width;
    self.dayPicker = [[EPInfinitePickerColumn alloc] initWithFrame:CGRectMake(0, 0, day_month_pos, self.bounds.size.height)];
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    [self addSubview:self.dayPicker];
    self.monthPicker = [[EPInfinitePickerColumn alloc] initWithFrame:CGRectMake(day_month_pos, 0, month_year_pos - day_month_pos, self.bounds.size.height)];
    self.monthPicker.delegate = self;
    self.monthPicker.dataSource = self;
    [self addSubview:self.monthPicker];
    self.yearPicker = [[EPInfinitePickerColumn alloc] initWithFrame:CGRectMake(month_year_pos, 0, self.bounds.size.width - month_year_pos, self.bounds.size.height)];
    self.yearPicker.delegate = self;
    self.yearPicker.dataSource = self;
    [self addSubview:self.yearPicker];
    
    
    self.textFont = [UIFont systemFontOfSize:20];
    self.selectedTextFont = [UIFont boldSystemFontOfSize:20];
    self.disabledTextFont = [UIFont systemFontOfSize:20];
    
    self.textColor = [UIColor darkGrayColor];
    self.selectedTextColor = [UIColor blackColor];
    self.disabledTextColor = [UIColor lightGrayColor];
}

- (void)infinitePickerColumn:(EPInfinitePickerColumn *)pickerColumn selectedRowAtIndex:(NSInteger)index
{
    NSInteger day = [self.calendar component:NSCalendarUnitDay fromDate:self.referenceDate];
    NSRange maxDayRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitDay];
    day = ((day + self.dayPicker.selectedRow - maxDayRange.location) % maxDayRange.length + maxDayRange.length) % maxDayRange.length + maxDayRange.location;
    NSInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:self.referenceDate];
    NSRange maxMonthRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitMonth];
    month = ((month + self.monthPicker.selectedRow - maxMonthRange.location) % maxMonthRange.length + maxMonthRange.length) % maxMonthRange.length + maxMonthRange.location;
    NSInteger year = [self.calendar component:NSCalendarUnitYear fromDate:self.referenceDate];
    year = year + self.yearPicker.selectedRow;
    BOOL willBeCorrected = NO;
    NSDateComponents *components = [[NSDateComponents alloc] init];

    NSRange yearRange = [self.calendar rangeOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:self.referenceDate];
    if (year - yearRange.location >= yearRange.length) {
        components.year = yearRange.location + yearRange.length - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow - (year - yearRange.location - yearRange.length + 1);
        
        willBeCorrected = YES;
    }
    else if (year < yearRange.location) {
        components.year = yearRange.location;
        _date = [self.calendar dateFromComponents:components];
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow + (yearRange.location - year);
        
        willBeCorrected = YES;
    }
    else
        components.year = year;

    NSRange monthRange = [self.calendar rangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:[self.calendar dateFromComponents:components]];
    if (month - monthRange.location >= monthRange.length) {
        components.month = monthRange.location + monthRange.length - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.monthPicker.selectedRow = self.monthPicker.selectedRow - (month - monthRange.location - monthRange.length + 1);
        
        willBeCorrected = YES;
    }
    else if (month < monthRange.location) {
        components.month = monthRange.location;
        _date = [self.calendar dateFromComponents:components];
        
        self.monthPicker.selectedRow = self.monthPicker.selectedRow + (monthRange.location - month);
        
        willBeCorrected = YES;
    }
    else
        components.month = month;
    
    NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self.calendar dateFromComponents:components]];
    if (day - dayRange.location >= dayRange.length) {
        components.day = dayRange.location + dayRange.length - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.dayPicker.selectedRow = self.dayPicker.selectedRow - (day - dayRange.location - dayRange.length + 1);

        willBeCorrected = YES;
    }
    else if (day < dayRange.location) {
        components.day = dayRange.location;
        _date = [self.calendar dateFromComponents:components];
        
        self.dayPicker.selectedRow = self.dayPicker.selectedRow + (dayRange.location - day);
        
        willBeCorrected = YES;
    }
    else
        components.day = day;
    
    self.components = components;
    
    if (willBeCorrected)
        return;
    
    NSDate *date = [self.calendar dateFromComponents:components];
    
    if (self.minDate != nil && [self.minDate compare:date] == NSOrderedDescending) {
        date = self.minDate;
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow + (self.minComponents.year - year);
        self.monthPicker.selectedRow = self.monthPicker.selectedRow + ((self.minComponents.month - month) % maxMonthRange.length + maxMonthRange.length) % maxMonthRange.length;
        self.dayPicker.selectedRow = self.dayPicker.selectedRow + ((self.minComponents.day - day) % maxDayRange.length + maxDayRange.length) % maxDayRange.length;
        
        components = self.minComponents;
        
        willBeCorrected = YES;
    }
    if (self.maxDate != nil && [self.maxDate compare:date] == NSOrderedAscending) {
        date = self.maxDate;
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow - (year - self.maxComponents.year);
        self.monthPicker.selectedRow = self.monthPicker.selectedRow + ((month - self.maxComponents.month) % maxMonthRange.length + maxMonthRange.length) % maxMonthRange.length;
        self.dayPicker.selectedRow = self.dayPicker.selectedRow + ((day - self.maxComponents.day) % maxDayRange.length + maxDayRange.length) % maxDayRange.length;
        
        components = self.maxComponents;
        
        willBeCorrected = YES;
    }
    
    _date = date;
    self.components = components;
    
    if (willBeCorrected)
        return;

    [self.dayPicker reloadData];
    
    NSLog(@"selected %@", self.date);
}

- (UIView *)infinitePickerColumn:(EPInfinitePickerColumn *)pickerColumn viewForRowAtIndex:(NSInteger)index selected:(BOOL)selected
{
    if (pickerColumn == self.dayPicker) {
        NSInteger day = [self.calendar component:NSCalendarUnitDay fromDate:self.referenceDate];
        NSRange dayRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitDay];
        day = ((day + index - dayRange.location) % dayRange.length + dayRange.length) % dayRange.length + dayRange.location;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.date];
            BOOL allowed = day - dayRange.location < dayRange.length;
            allowed = allowed && (self.minDate == nil || self.minComponents.year < self.components.year || (self.minComponents.year == self.components.year && (self.minComponents.month < self.components.month || (self.minComponents.month == self.components.month && self.minComponents.day <= day))));
            allowed = allowed && (self.maxDate == nil || self.maxComponents.year > self.components.year || (self.maxComponents.year == self.components.year && (self.maxComponents.month > self.components.month || (self.maxComponents.month == self.components.month && self.maxComponents.day >= day))));
            if (!allowed) {
                label.font = self.disabledTextFont;
                label.textColor = self.disabledTextColor;
            }
            else {
                label.font = self.textFont;
                label.textColor = self.textColor;
            }
        }
        
        label.text = [NSString stringWithFormat:@"%ld", (long)day];
        return label;
    }
    if (pickerColumn == self.monthPicker) {
        NSInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:self.referenceDate];
        NSRange monthRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitMonth];
        month = ((month + index - monthRange.location) % monthRange.length + monthRange.length) % monthRange.length + monthRange.location;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            NSRange monthRange = [self.calendar rangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self.date];
            BOOL allowed = month - monthRange.location < monthRange.length;
            allowed = allowed && (self.minDate == nil || self.minComponents.year < self.components.year || (self.minComponents.year == self.components.year && (self.minComponents.month <= month)));
            allowed = allowed && (self.maxDate == nil || self.maxComponents.year > self.components.year || (self.maxComponents.year == self.components.year && (self.maxComponents.month >= month)));
            if (!allowed) {
                label.font = self.disabledTextFont;
                label.textColor = self.disabledTextColor;
            }
            else {
                label.font = self.textFont;
                label.textColor = self.textColor;
            }
        }
        label.text = [NSString stringWithFormat:@"%@", self.dateFormatter.monthSymbols[month - monthRange.location]];
        return label;
    }
    if (pickerColumn == self.yearPicker) {
        NSInteger year = [self.calendar component:NSCalendarUnitYear fromDate:self.referenceDate];
        NSRange yearRange = [self.calendar rangeOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:self.date];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            BOOL allowed = year - yearRange.location < yearRange.length;
            allowed = allowed && (self.minDate == nil || self.minComponents.year <= year);
            allowed = allowed && (self.maxDate == nil || self.maxComponents.year >= year);
            label.font = self.textFont;
            label.textColor = self.textColor;
        }
        if (year - yearRange.location < yearRange.length)
            label.text = [NSString stringWithFormat:@"%ld", (long)(year + index)];
        else
            label.text = @"";
        return label;
    }
    
    return nil;
}

- (void)setDate:(NSDate *)date
{
    if (date == nil)
        _date = [NSDate date];
    else
        _date = date;
    self.components = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    self.referenceDate = self.date;
    [self resetColumns];
}

- (void)setCalendar:(NSCalendar *)calendar
{
    if (calendar == nil)
        _calendar = [NSCalendar currentCalendar];
    else
        _calendar = calendar;
    
    [self resetColumns];
}

- (void)setTimezone:(NSTimeZone *)timezone
{
    if (timezone == nil)
        timezone = [NSTimeZone localTimeZone];
    _timezone = timezone;
    self.calendar.timeZone = timezone;
    self.dateFormatter.timeZone = timezone;
}

- (void)setMinDate:(NSDate *)minDate
{
    _minDate = minDate;
    if (minDate != nil) {
        self.minComponents = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:minDate];
        if ([minDate compare:self.date] == NSOrderedDescending)
            self.date = minDate;
        self.yearPicker.minRow = self.minComponents.year - self.components.year;
    }
    else {
        self.maxComponents = nil;
        self.yearPicker.minRow = LONG_MIN;
    }
    [self resetColumns];
}

- (void)setMaxDate:(NSDate *)maxDate
{
    _maxDate = maxDate;
    if (maxDate != nil) {
        self.maxComponents = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:maxDate];
        if ([maxDate compare:self.date] == NSOrderedAscending)
            self.date = maxDate;
        self.yearPicker.maxRow = self.minComponents.year - self.components.year;
    }
    else {
        self.maxComponents = nil;
        self.yearPicker.maxRow = LONG_MAX;
    }
    [self resetColumns];
}

- (void)resetColumns
{
    self.dayPicker.selectedRow = 0;
    self.monthPicker.selectedRow = 0;
    self.yearPicker.selectedRow = 0;
    self.referenceDate = self.date;
    [self.dayPicker reloadData];
    [self.monthPicker reloadData];
    [self.yearPicker reloadData];
}

@end
