//
//  WTNMovieTableViewCell_TEMP.m
//  Watch2Night
//
//  Created by qw on 11.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNMovieTableViewCell_TEMP.h"

#import "WTNMovie.h"

#import "WTNDefines.h"


@implementation WTNMovieTableViewCell_TEMP{

    id _posterObserver;
    id _rateObserver;
    id _cinemaInfosObserver;
}

- (void)setMovie:(WTNMovie *)movie{

    _movie                   = movie;
    
    self.movieNameLabel.text = movie.name;
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    __block WTNMovieTableViewCell_TEMP *__self = self;
    
    _posterObserver = nil;
    _rateObserver   = nil;
    
    if (!movie.poster) {
     
        _posterObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MOVIE_POSTER_UPDATED
                                                                            object:movie
                                                                             queue:[NSOperationQueue mainQueue]
                                                                        usingBlock:^(NSNotification *note) {
                                                                            
                                                                            __self.posterImageView.image = movie.poster;
                                                                            
//                                                                            _posterObserver              = nil;
                                                                        }];
    }
    else{
        _posterImageView.image = movie.poster;
    }


    if (movie.rate.length == 0) {

        _rateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MOVIE_RATE_UPDATED
                                                                          object:movie
                                                                           queue:[NSOperationQueue mainQueue]
                                                                      usingBlock:^(NSNotification *note) {
                                                                          
                                                                          __self.rateLabel.text = movie.rate;
                                                                          
//                                                                          _rateObserver              = nil;
                                                                      }];
    }
    else{
        
        _rateLabel.text = movie.rate;
    }

}

@end
