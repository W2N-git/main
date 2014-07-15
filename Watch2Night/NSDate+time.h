//
//  NSDate+time.h
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (time)

+ (instancetype)dateWithHours:(NSInteger)hours minutes:(NSInteger)minutes;
+ (instancetype)nextDayDateWithHours:(NSInteger)hours minutes:(NSInteger)minutes;


@end
