//
//  WTNCity.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTNCity : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy) NSString   *cityName;
@property (nonatomic, copy) NSString   *countryName;

@property (nonatomic, copy) CLLocation *location;

@property (nonatomic, copy) NSString   *code;

- (id)initWithPlacemark:(CLPlacemark *)placemark;


@end
