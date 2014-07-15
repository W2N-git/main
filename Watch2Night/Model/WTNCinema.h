//
//  WTNCinema.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTNFilmshow;

@interface WTNCinema : NSObject <NSCopying, NSCoding>

@property (nonatomic, copy)     NSString   *name;
@property (nonatomic, copy)     NSString   *address;
@property (nonatomic, copy)     CLLocation *location;

@property (nonatomic, copy)     NSArray    *filmshows;

@property (nonatomic)           BOOL        isCinema;

//- (instancetype)initWithInfoFromGoogle:(NSDictionary *)info;
//- (instancetype)initWithInfoFromYandex:(NSDictionary *)info;

- (WTNFilmshow *)firstFilmShow;

@end
