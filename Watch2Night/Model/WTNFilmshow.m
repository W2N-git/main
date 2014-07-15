//
//  WTNFilmshow.m
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNFilmshow.h"
#import "WTNCinema.h"
#import "WTNMovie.h"

#import "WTNDataManager.h"

#import "NSDate+time.h"

@implementation WTNFilmshow

- (instancetype)initWithCinema:(WTNCinema *)cinema movie:(WTNMovie *)movie time:(NSString *)time{

    if (self = [super init]) {
        
        self.cinema = cinema;
        self.movie  = movie;
        self.time   = time;
        
        [self prepareDate];
    }
    return self;
}

- (void)prepareDate{

    NSArray   *timeComponents = [self.time componentsSeparatedByString:@":"];
    
    NSInteger hours   = [timeComponents[0] integerValue];
    NSInteger minutes = [timeComponents[1] integerValue];
    
    
    if (hours >= 6) {
        self.fullDate = [NSDate dateWithHours:hours minutes:minutes];
    }
    else{
        self.fullDate = [NSDate nextDayDateWithHours:hours minutes:minutes];
    }
}

- (NSString *)description{

    return [NSString stringWithFormat:@"%@ %@ %@", self.cinema.name, self.movie.name,  self.time];
}

#pragma mark - 

- (id)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        
        self.time = [aDecoder decodeObjectForKey:@"time"];
        [self prepareDate];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.time forKey:@"time"];
}

@end
