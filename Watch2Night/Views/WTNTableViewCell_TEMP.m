//
//  WTNTableViewCell_TEMP.m
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNTableViewCell_TEMP.h"

#import "WTNMovie.h"
#import "WTNCinema.h"
#import "WTNFilmshow.h"

@implementation WTNTableViewCell_TEMP

- (void)setCinema:(WTNCinema *)cinema{

    _cinema = cinema;

//    NSMutableArray *times = [NSMutableArray array];
//    
//    for (NSInteger i = 0; i < cinema.filmshows.count; i++) {
//        [times addObject:[cinema.filmshows[i] time]];
//    }
//    
//    self.times.text = [times componentsJoinedByString:@" "];
    
    WTNFilmshow *firstFilmShow = cinema.firstFilmShow;
    
    if (!firstFilmShow) {
        self.times.text      = [[cinema.filmshows lastObject] time];
        self.times.textColor = [UIColor grayColor];
    }
    else{
        self.times.text = cinema.firstFilmShow.time;
        self.times.textColor = [UIColor blackColor];
    }
    
}

@end
