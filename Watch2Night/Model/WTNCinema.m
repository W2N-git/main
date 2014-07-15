//
//  WTNCinema.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNCinema.h"

#import "WTNFilmshow.h"


@implementation WTNCinema

/*
- (instancetype)initWithInfoFromGoogle:(NSDictionary *)info{

    if (self = [super init]) {
        
        self.name     = info[@"name"];
        self.address  = info[@"formatted_address"];
        
        self.address  = self.address.length == 0 ? info[@"vicinity"] : self.address;
    
        self.location = [[CLLocation alloc] initWithLatitude:[info[@"geometry"][@"location"][@"lat"] doubleValue]
                                                   longitude:[info[@"geometry"][@"location"][@"lng"] doubleValue]];
    
    }
    return self;
}

- (instancetype)initWithInfoFromYandex:(NSDictionary *)info{

    if (self = [super init]) {

        NSDictionary *GeoObject  = info[@"GeoObject"];
        
        self.name                = GeoObject[@"name"];
        self.address             = GeoObject[@"metaDataProperty"][@"PSearchObjectMetaData"][@"address"];
        NSArray *coordComponents = [GeoObject[@"Point"][@"pos"] componentsSeparatedByString:@" "];
        
        self.location            = [[CLLocation alloc] initWithLatitude:[coordComponents[0] doubleValue]
                                                              longitude:[coordComponents[1] doubleValue]];
        
        
        NSString *category       = GeoObject[@"metaDataProperty"][@"PSearchObjectMetaData"][@"category"];
        
        if ([[category lowercaseString] isEqualToString:@"кинотеатр"]) {
            self.isCinema = YES;
        }
    }
    return self;
}
*/


- (NSString *)description{

    return [NSString stringWithFormat:@"%@ (%@) (%f %f)", self.name.description, self.address.description, self.location.coordinate.latitude, self.location.coordinate.longitude];
}

#pragma mark - 

- (id)copyWithZone:(NSZone *)zone{

    WTNCinema *copy = [[WTNCinema alloc] init];

    copy.name       = [self.name     copy];
    copy.address    = [self.address  copy];
    copy.location   = [self.location copy];

    return copy;
}

#pragma mark - 

- (id)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        
        self.name       = [aDecoder decodeObjectForKey:@"name"];
        self.address    = [aDecoder decodeObjectForKey:@"address"];
        NSData *locationData   = [aDecoder decodeObjectForKey:@"location"];
        
        self.location = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
        
//        self.filmshows  = [aDecoder decodeObjectForKey:@"filmshows"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeObject:self.name     forKey:@"name"];
    [aCoder encodeObject:self.address  forKey:@"address"];
    
    NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:self.location];
    
    [aCoder encodeObject:locationData forKey:@"location"];
    
//    [aCoder encodeObject:self.filmshows forKey:@"filmshows"];
}

#pragma mark - 

- (WTNFilmshow *)firstFilmShow{

    WTNFilmshow *targetFilmshow = nil;
    
    NSDate      *currentDate    = [NSDate date];
    NSDate      *minDate        = [NSDate dateWithTimeIntervalSinceNow:86400];
    
    for (NSInteger i = 0; i < self.filmshows.count; i++) {
        
        WTNFilmshow *filmshow = self.filmshows[i];
        
        NSDate *date = filmshow.fullDate;
        
        if ([date compare:currentDate] == NSOrderedAscending) {
            continue;
        }
        
        if ([date compare:minDate] == NSOrderedAscending) {
           
            minDate        = date;
            targetFilmshow = filmshow;
        }
    }
        
    return targetFilmshow;
}

@end
