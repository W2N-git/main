//
//  WTNFilmshow.h
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>


@class WTNCinema;
@class WTNMovie;

@interface WTNFilmshow : NSObject <NSCoding>

@property (nonatomic, unsafe_unretained) WTNMovie  *movie;
@property (nonatomic, unsafe_unretained) WTNCinema *cinema;


@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSDate   *fullDate;

@property (nonatomic)         BOOL      isValid;

- (instancetype)initWithCinema:(WTNCinema *)cinema movie:(WTNMovie *)movie time:(NSString *)time;

@end
