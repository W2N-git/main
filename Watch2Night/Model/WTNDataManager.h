//
//  WTNDataManager.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WTNCity;
@class WTNCinema;
@class WTNMovie;

@interface WTNDataManager : NSObject

+ (instancetype)sharedManager;
- (void)prepareForWork;



@property (nonatomic, strong) NSDate  *lastDate;

@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) WTNCity *lastCity;

- (void)getCitiesFromPage;
- (WTNCity *)cityWithName:(NSString *)name;

- (void)saveCities;
- (void)loadCitiesLocally;


@property (nonatomic, strong) NSArray *cinemas;

- (WTNCinema *)cinemaWithName:(NSString *)name;
- (void)getCimenasFromPage;

- (void)saveCinemas;
- (void)loadCinemasLocally;


@property (nonatomic, strong) NSArray *movies;

- (void)getMovies;

- (void)saveMovies;
- (void)loadMoviesLocally;

//- (void)savePosterOfMovie:(WTNMovie *)movie;
//- (UIImage *)posterOfMovieOfMovie:(WTNMovie *)movie;


- (void)saveImageData:(NSData *)data withName:(NSString *)name;
- (UIImage *)imageWithName:(NSString *)name;

@end
