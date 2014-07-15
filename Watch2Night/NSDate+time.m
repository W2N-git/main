//
//  NSDate+time.m
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "NSDate+time.h"

static NSCalendar *st_gregorian;

@implementation NSDate (time)

+ (instancetype)dateWithHours:(NSInteger)hours minutes:(NSInteger)minutes{

    NSDate *date = [NSDate date];
    
    if (!st_gregorian)
        st_gregorian   =   [[NSCalendar    alloc]  initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSCalendarUnit components = NSYearCalendarUnit  |
                                NSMonthCalendarUnit |
                                NSDayCalendarUnit   |
                                NSHourCalendarUnit  |
                                NSMinuteCalendarUnit;
    
    NSDateComponents *selfComponents  = [st_gregorian  components:components  fromDate:date];
    
//    NSLog(@"selfComponents : %d, %d", selfComponents.hour, selfComponents.minute);

    selfComponents.hour   = hours;
    selfComponents.minute = minutes;

//    NSLog(@"selfComponents : %d, %d", selfComponents.hour, selfComponents.minute);
    
    return [st_gregorian dateFromComponents:selfComponents];
}

+ (instancetype)nextDayDateWithHours:(NSInteger)hours minutes:(NSInteger)minutes{
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:86400];
    
    if (!st_gregorian)
        st_gregorian   =   [[NSCalendar    alloc]  initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSCalendarUnit components = NSYearCalendarUnit  |
                                NSMonthCalendarUnit |
                                NSDayCalendarUnit   |
                                NSHourCalendarUnit  |
                                NSMinuteCalendarUnit;
    
    NSDateComponents *selfComponents  = [st_gregorian  components:components  fromDate:date];
    
//    NSLog(@"selfComponents : %d, %d", selfComponents.hour, selfComponents.minute);
    
    selfComponents.hour   = hours;
    selfComponents.minute = minutes;
    
//    NSLog(@"selfComponents : %d, %d", selfComponents.hour, selfComponents.minute);
    
    return [st_gregorian dateFromComponents:selfComponents];
}

@end
