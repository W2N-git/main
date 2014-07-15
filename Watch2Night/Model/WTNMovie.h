//
//  WTNMovie.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTNFilmshow;

@interface WTNMovie : NSObject <NSCoding>

@property (nonatomic, copy)   NSString *name;

@property (nonatomic, copy)   NSString *hReference;

@property (nonatomic, copy)   NSString *movieDescription;
@property (nonatomic, copy)   NSString *movieId;
@property (nonatomic, strong) UIImage  *poster;
@property (nonatomic, copy)   NSString *rate;

@property (nonatomic, readonly) NSArray  *cinemas;


- (void)updateCinemasInfo;
//- (void)updatePoster;
//- (void)updateRate;

- (void)updateRateAndPoster;

- (WTNFilmshow *)firstFilmShow;
- (WTNFilmshow *)nearestFilmshowByPlace;

@end
