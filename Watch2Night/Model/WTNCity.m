//
//  WTNCity.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNCity.h"

@implementation WTNCity

- (id)initWithPlacemark:(CLPlacemark *)placemark{

    if (self = [super init]) {

        self.cityName    = placemark.locality;
        self.countryName = placemark.country;
        self.location    = placemark.location;
    
    }
    
    return self;
}

- (BOOL)isEqual:(WTNCity *)object{

    return [self.countryName isEqualToString:object.countryName] &&
           [self.cityName    isEqualToString:object.cityName];
    
}

#pragma mark -

- (id)initWithCoder:(NSCoder *)aDecoder{
 
    if (self = [super init]) {
        self.cityName    = [aDecoder decodeObjectForKey:@"city_name"];
        self.countryName = [aDecoder decodeObjectForKey:@"country_name"];
        NSData *locationData   = [aDecoder decodeObjectForKey:@"location"];
        
        self.location = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
        self.code        = [aDecoder decodeObjectForKey:@"code"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeObject:self.cityName      forKey:@"city_name"];
    [aCoder encodeObject:self.countryName   forKey:@"country_name"];
    
    NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:self.location];
    
    [aCoder encodeObject:locationData forKey:@"location"];
    
    [aCoder encodeObject:self.code          forKey:@"code"];
    
}

- (id)copyWithZone:(NSZone *)zone{
 
    WTNCity *city = [WTNCity new];
    
    if (city) {
        city.cityName    = self.cityName;
        city.countryName = self.countryName;
        city.location    = self.location;
        city.code        = self.code;
    }
    
    return city;
}


@end
