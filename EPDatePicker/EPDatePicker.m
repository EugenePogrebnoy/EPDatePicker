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
@property (copy, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

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
    self.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
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
    day = ((day + self.dayPicker.selectedRow - 1) % 31 + 31) % 31 + 1;
    NSInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:self.referenceDate];
    month = ((month + self.monthPicker.selectedRow - 1) % 12 + 12) % 12 + 1;
    NSInteger year = [self.calendar component:NSCalendarUnitYear fromDate:self.referenceDate];
    year = year + self.yearPicker.selectedRow;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = month;
    components.year = year;
    
    NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self.calendar dateFromComponents:components]];
    if (day - dayRange.location >= dayRange.length) {
        components.day = dayRange.location + dayRange.length - 1;
        _date = [self.calendar dateFromComponents:components];
        
        self.dayPicker.selectedRow = self.dayPicker.selectedRow - (day - dayRange.location - dayRange.length + 1);

        return;
    }
    
    components.day = day;
    _date = [self.calendar dateFromComponents:components];

    [self.dayPicker reloadData];
    
    NSLog(@"selected %@", self.date);
}

- (UIView *)infinitePickerColumn:(EPInfinitePickerColumn *)pickerColumn viewForRowAtIndex:(NSInteger)index selected:(BOOL)selected
{
    if (pickerColumn == self.dayPicker) {
//        NSDate *rowDate = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:index toDate:self.referenceDate options:0];
        NSInteger day = [self.calendar component:NSCalendarUnitDay fromDate:self.referenceDate];
        day = ((day + index - 1) % 31 + 31) % 31 + 1;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.date];
            if (day - dayRange.location >= dayRange.length) {
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
//        NSDate *rowDate = [self.calendar dateByAddingUnit:NSCalendarUnitMonth value:index toDate:self.referenceDate options:0];
        NSInteger month = [self.calendar component:NSCalendarUnitMonth fromDate:self.referenceDate];
        month = ((month + index - 1) % 12 + 12) % 12 + 1;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            label.font = self.textFont;
            label.textColor = self.textColor;
        }
        label.text = [NSString stringWithFormat:@"%@", self.dateFormatter.monthSymbols[month - 1]];
        return label;
    }
    if (pickerColumn == self.yearPicker) {
//        NSDate *rowDate = [self.calendar dateByAddingUnit:NSCalendarUnitYear value:index toDate:self.referenceDate options:0];
        NSInteger year = [self.calendar component:NSCalendarUnitYear fromDate:self.referenceDate];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        if (selected) {
            label.font = self.selectedTextFont;
            label.textColor = self.selectedTextColor;
        }
        else {
            label.font = self.textFont;
            label.textColor = self.textColor;
        }
        label.text = [NSString stringWithFormat:@"%ld", (long)(year + index)];
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

- (void)resetColumns
{
    self.dayPicker.selectedRow = 0;
    self.monthPicker.selectedRow = 0;
    self.yearPicker.selectedRow = 0;
    [self.dayPicker reloadData];
    [self.monthPicker reloadData];
    [self.yearPicker reloadData];
}

@end
