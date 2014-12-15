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
    _calendar = [NSCalendar currentCalendar];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    _timeZone = [NSTimeZone localTimeZone];
    _calendar.timeZone = _timeZone;
    _dateFormatter.timeZone = _timeZone;
    self.date = [NSDate date];
    
    CGFloat day_month_pos = 0.19 * self.bounds.size.width;
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
    if (self.dayPicker.isInAnimation || self.monthPicker.isInAnimation || self.yearPicker.isInAnimation)
        return;
    
    NSInteger day = [self.calendar component:NSCalendarUnitDay fromDate:self.referenceDate];
    NSRange maxDayRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitDay];
    NSInteger maxDayRangeStart = maxDayRange.location;
    NSInteger maxDayRangeLength = maxDayRange.length;
    day = ((day + self.dayPicker.selectedRow - maxDayRangeStart) % maxDayRangeLength + maxDayRangeLength) % maxDayRangeLength + maxDayRangeStart;
    NSInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:self.referenceDate];
    NSRange maxMonthRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitMonth];
    NSInteger maxMonthRangeStart = maxMonthRange.location;
    NSInteger maxMonthRangeLength = maxMonthRange.length;
    month = ((month + self.monthPicker.selectedRow - maxMonthRangeStart) % maxMonthRangeLength + maxMonthRangeLength) % maxMonthRangeLength + maxMonthRangeStart;
    NSInteger year = [self.calendar component:NSCalendarUnitYear fromDate:self.referenceDate];
    year = year + self.yearPicker.selectedRow;
    BOOL willBeCorrected = NO;
    NSDateComponents *components = [[NSDateComponents alloc] init];

    NSRange yearRange = [self.calendar rangeOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:self.referenceDate];
    NSInteger yearRangeStart = yearRange.location;
    NSInteger yearRangeLength = yearRange.length;
    if (year - yearRangeStart >= yearRangeLength) {
        components.year = yearRangeStart + yearRangeLength - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow - (year - yearRangeStart - yearRangeLength + 1);
        
        willBeCorrected = YES;
    }
    else if (year < yearRangeStart) {
        components.year = yearRangeStart;
        _date = [self.calendar dateFromComponents:components];
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow + (yearRangeStart - year);
        
        willBeCorrected = YES;
    }
    else
        components.year = year;

    NSRange monthRange = [self.calendar rangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:[self.calendar dateFromComponents:components]];
    NSInteger monthRangeStart = monthRange.location;
    NSInteger monthRangeLength = monthRange.length;
    if (month - monthRangeStart >= monthRangeLength) {
        components.month = monthRangeStart + monthRangeLength - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.monthPicker.selectedRow = self.monthPicker.selectedRow - (month - monthRangeStart - monthRangeLength + 1);
        
        willBeCorrected = YES;
    }
    else if (month < monthRangeStart) {
        components.month = monthRangeStart;
        _date = [self.calendar dateFromComponents:components];
        
        self.monthPicker.selectedRow = self.monthPicker.selectedRow + (monthRangeStart - month);
        
        willBeCorrected = YES;
    }
    else
        components.month = month;
    
    NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self.calendar dateFromComponents:components]];
    NSInteger dayRangeStart = dayRange.location;
    NSInteger dayRangeLength = dayRange.length;
    if (day - dayRangeStart >= dayRangeLength) {
        components.day = dayRangeStart + dayRangeLength - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.dayPicker.selectedRow = self.dayPicker.selectedRow - (day - dayRangeStart - dayRangeLength + 1);

        willBeCorrected = YES;
    }
    else if (day < dayRangeStart) {
        components.day = dayRangeStart;
        _date = [self.calendar dateFromComponents:components];
        
        self.dayPicker.selectedRow = self.dayPicker.selectedRow + (dayRangeStart - day);
        
        willBeCorrected = YES;
    }
    else
        components.day = day;
    
    self.components = components;
    
    if (willBeCorrected)
        return;
    
    NSDate *date = [self.calendar dateFromComponents:components];
    
    if (self.minimumDate != nil && [self.minimumDate compare:date] == NSOrderedDescending) {
        date = self.minimumDate;
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow + (self.minComponents.year - year);
        self.monthPicker.selectedRow = self.monthPicker.selectedRow + ((self.minComponents.month - month) % maxMonthRangeLength + maxMonthRangeLength) % maxMonthRangeLength;
        self.dayPicker.selectedRow = self.dayPicker.selectedRow + ((self.minComponents.day - day) % maxDayRangeLength + maxDayRangeLength) % maxDayRangeLength;
        
        components = self.minComponents;
        
        willBeCorrected = YES;
    }
    if (self.maximumDate != nil && [self.maximumDate compare:date] == NSOrderedAscending) {
        date = self.maximumDate;
        
        self.yearPicker.selectedRow = self.yearPicker.selectedRow - (year - self.maxComponents.year);
        self.monthPicker.selectedRow = self.monthPicker.selectedRow - ((month - self.maxComponents.month) % maxMonthRangeLength + maxMonthRangeLength) % maxMonthRangeLength;
        self.dayPicker.selectedRow = self.dayPicker.selectedRow - ((day - self.maxComponents.day) % maxDayRangeLength + maxDayRangeLength) % maxDayRangeLength;
        
        components = self.maxComponents;
        
        willBeCorrected = YES;
    }
    
    _date = date;
    self.components = components;
    
    if (willBeCorrected)
        return;

    [self.dayPicker reloadData];
    [self.monthPicker reloadData];
    
    CLS_LOG(@"selected %@", self.date);
//    NSLog(@"selected %@", self.date);
}

- (UIView *)infinitePickerColumn:(EPInfinitePickerColumn *)pickerColumn viewForRowAtIndex:(NSInteger)index selected:(BOOL)selected
{
    if (pickerColumn == self.dayPicker) {
        NSInteger day = [self.calendar component:NSCalendarUnitDay fromDate:self.referenceDate];
        NSRange dayRange = [self.calendar maximumRangeOfUnit:NSCalendarUnitDay];
        NSInteger rangeStart = dayRange.location;
        NSInteger rangeLength = dayRange.length;
        day = ((day + index - rangeStart) % rangeLength + rangeLength) % rangeLength + rangeStart;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.date];
            BOOL allowed = day - dayRange.location < dayRange.length;
            allowed = allowed && (self.minimumDate == nil || self.minComponents.year < self.components.year || (self.minComponents.year == self.components.year && (self.minComponents.month < self.components.month || (self.minComponents.month == self.components.month && self.minComponents.day <= day))));
            allowed = allowed && (self.maximumDate == nil || self.maxComponents.year > self.components.year || (self.maxComponents.year == self.components.year && (self.maxComponents.month > self.components.month || (self.maxComponents.month == self.components.month && self.maxComponents.day >= day))));
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
        NSInteger rangeStart = monthRange.location;
        NSInteger rangeLength = monthRange.length;
        month = ((month + index - rangeStart) % rangeLength + rangeLength) % rangeLength + rangeStart;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            NSRange monthRange = [self.calendar rangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self.date];
            BOOL allowed = month - monthRange.location < monthRange.length;
            allowed = allowed && (self.minimumDate == nil || self.minComponents.year < self.components.year || (self.minComponents.year == self.components.year && (self.minComponents.month <= month)));
            allowed = allowed && (self.maximumDate == nil || self.maxComponents.year > self.components.year || (self.maxComponents.year == self.components.year && (self.maxComponents.month >= month)));
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
        year = year + index;
        NSRange yearRange = [self.calendar rangeOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:self.date];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            BOOL allowed = year - yearRange.location < yearRange.length;
            allowed = allowed && (self.minimumDate == nil || self.minComponents.year <= year);
            allowed = allowed && (self.maximumDate == nil || self.maxComponents.year >= year);
            
            if (!allowed) {
                label.font = self.disabledTextFont;
                label.textColor = self.disabledTextColor;
            }
            else {
                label.font = self.textFont;
                label.textColor = self.textColor;
            }
        }
        if (year - yearRange.location < yearRange.length)
            label.text = [NSString stringWithFormat:@"%ld", (long)year];
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

- (void)setReferenceDate:(NSDate *)referenceDate
{
    _referenceDate = referenceDate;
    NSInteger year = [self.calendar component:NSCalendarUnitYear fromDate:referenceDate];
    NSRange yearRange = [self.calendar rangeOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:referenceDate];
    self.yearPicker.minRow = yearRange.location - year;
    self.yearPicker.maxRow = yearRange.location + yearRange.length - 1 - year;
    if (self.minimumDate != nil)
        self.yearPicker.minRow = MAX(self.yearPicker.minRow, self.minComponents.year - year);
    if (self.maximumDate != nil)
        self.yearPicker.maxRow = MIN(self.yearPicker.maxRow, self.maxComponents.year - year);
}

- (void)setCalendar:(NSCalendar *)calendar
{
    if (calendar == nil)
        _calendar = [NSCalendar currentCalendar];
    else
        _calendar = calendar;
    
    [self resetColumns];
}

- (void)setTimeZone:(NSTimeZone *)timeZone
{
    if (timeZone == nil)
        timeZone = [NSTimeZone localTimeZone];
    _timeZone = timeZone;
    self.calendar.timeZone = timeZone;
    self.dateFormatter.timeZone = timeZone;
}

- (void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
    if (minimumDate != nil) {
        self.minComponents = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:minimumDate];
        if ([minimumDate compare:self.date] == NSOrderedDescending)
            self.date = minimumDate;
        self.yearPicker.minRow = self.minComponents.year - self.components.year;
    }
    else {
        self.maxComponents = nil;
        self.referenceDate = self.referenceDate;
    }
    [self resetColumns];
}

- (void)setMaximumDate:(NSDate *)maximumDate
{
    _maximumDate = maximumDate;
    if (maximumDate != nil) {
        self.maxComponents = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:maximumDate];
        if ([maximumDate compare:self.date] == NSOrderedAscending)
            self.date = maximumDate;
        self.yearPicker.maxRow = self.minComponents.year - self.components.year;
    }
    else {
        self.maxComponents = nil;
        self.referenceDate = self.referenceDate;
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
