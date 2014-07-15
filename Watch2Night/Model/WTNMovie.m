//
//  WTNMovie.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNMovie.h"

#import "WTNDataManager.h"
#import "WTNCinema.h"
#import "WTNFilmshow.h"


#import "NMURLRequest.h"
#import "WTNDefines.h"

#import "WTNLocationsManager.h"


//(Рейтинг: [0-9],{0,1}[0-9]\/10)(?>.)*?голосов

static NSRegularExpression * st_placeTableLineRegex;
static NSRegularExpression * st_placeNameRegex;
static NSRegularExpression * st_timeRegex;

static NSRegularExpression * st_rateRegex;
static NSRegularExpression * st_hrefRegex;


@interface WTNMovie ()

@property (nonatomic, strong) NSMutableArray * cinemas;
@property (nonatomic, strong) NSArray        * filmshows;

@end

@implementation WTNMovie


+ (void)initialize{

    NSError *error = nil;
    
    st_rateRegex   = [[NSRegularExpression alloc] initWithPattern:@"Рейтинг:(?>.)*?([0-9],{0,1}[0-9]\\/10)(?>.)*?голос"
                                                          options:0
                                                            error:&error];
    
    if (error) {
        // NSLog(@"%s %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }

//    st_hrefRegex  = [[NSRegularExpression alloc] initWithPattern:@"www\\.kinopoisk\\.ru\\/film\\/([0-9]*?)\\/"
//                                                         options:0
//                                                           error:&error];

    st_hrefRegex = [[NSRegularExpression alloc] initWithPattern:@"(?><p(?>.)*?>(?>.)*?title=\"(?>.)*?\\/(?>([0-9]*?).jpg)(?>.)*?<\\/p>)"
                                                        options:0
                                                          error:&error];
    
//    (?><p(?>.)*?>(?>.)*?title="(?>.)*?\/(?>([0-9]*?).jpg)(?>.)*?<\/p>)
    
    if (error) {
        // NSLog(@"%s %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }
    
//  строки в таблице  <tr(?>.)*?class(?>.)*?=(?>.)*?"(?>.)*?place(?>.)*?>((?>.)*?)<\/tr>
//  название кинотеатра <a(?>.)*?>((?>.)*?)<\/a>
//  время               (?>\s)*?([0-9]{2}:[0-9]{2})(?>\s)*?
    
    st_placeTableLineRegex = [[NSRegularExpression alloc] initWithPattern:@"(?><(?>\\s)*?tr(?>\\s)*?>((?>.)*?)<\\/tr>)"
                                                                  options:0
                                                                    error:&error];
    
    if (error) {
        // NSLog(@"%s %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }

    st_placeNameRegex = [[NSRegularExpression alloc] initWithPattern:@"(?><(?>\\s)*?a(?>\\s)*?href(?>\\s)*?=(?>\\s)*?\"\\/[a-zA-Z]{0,3}?\\/places\\/(?>.)*?\\/\"(?>.)*?>((?>.)*?)<\\/a>)"
                                                                  options:0
                                                                    error:&error];
    
    if (error) {
        // NSLog(@"%s %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }

    st_timeRegex = [[NSRegularExpression alloc] initWithPattern:@"(?>\\s)*?([0-9]{2}:[0-9]{2})(?>\\s)*?"
                                                                  options:0
                                                                    error:&error];
    
    if (error) {
        // NSLog(@"%s %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }
    
}


- (void)updateCinemasInfo{
    
    __block  WTNMovie *__self = self;
    
    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:self.hReference
                                                    andParams:@{@"limit" : @"1000"}
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                                     
                                                   if (status != 200) {
                                                       
                                                       [__self updateCinemasInfo];
                                                       return;
                                                   }
                                                   
                                                   dispatch_async(dispatch_queue_create("QUEUE", NULL),^{

                                                       [__self handleUpdateCinemasInfoResponse:response];
                                                   });
                                                   
                                               } andFailBlock:^(NSError *error) {
                                                   
                                                   // NSLog(@"%s line : %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
                                               }];
    [request start];
}

- (void)handleUpdateCinemasInfoResponse:(id)response{

    //  строки в таблице  <tr(?>.)*?class(?>.)*?=(?>.)*?"(?>.)*?place(?>.)*?>((?>.)*?)<\/tr>
    //  название кинотеатра <a(?>.)*?>((?>.)*?)<\/a>
    //  время               (?>\s)*?([0-9]{2}:[0-9]{2})(?>\s)*?
    //  прим. время не ограничивается 24:00, данные захватывают ночь следующего дня
    
    
    
    // вычленить информацию о сеансах
    // найти в дата - менеджере соответсвующие кинотеатры
    // правильно сохранить всю информацию
    
#warning needs multi-thread
    
    NSString *string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // NSLog(@"%s response : %@", __PRETTY_FUNCTION__, string);
    
    NSArray  *matches = [st_placeTableLineRegex matchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, string.length)];
    
    if (matches.count == 0 ) {
        // NSLog(@"something wrong with place table line");
    }
    
    NSMutableArray *cinemas = [NSMutableArray array];
    
    for (NSInteger i = 0; i < matches.count; i++) {
        
        // NSLog(@"\n\n");
        
        NSString *placeString = [string substringWithRange:[(NSTextCheckingResult *)matches[i] range]];
        
        NSTextCheckingResult *placeNameMatch = [st_placeNameRegex firstMatchInString:placeString
                                                                        options:0
                                                                          range:NSMakeRange(0, placeString.length)];
        
        if (!placeNameMatch) {
            continue;
        }
        
        NSString *placeName = nil;
        
        if (placeNameMatch){
        
            if (placeNameMatch.numberOfRanges > 1) {
            
                placeName = [placeString substringWithRange:[placeNameMatch rangeAtIndex:1]];
//                // NSLog(@"placeName : %@", placeName);
            }
            else{
                // NSLog(@"something wrong with place name");
            }
        }
        
        WTNCinema *cinema = [(WTNCinema *)[[WTNDataManager sharedManager] cinemaWithName:placeName] copy];
        
        NSArray *timeMatches = [st_timeRegex matchesInString:placeString
                                                     options:0
                                                       range:NSMakeRange(0, placeString.length)];
        
        
        NSMutableArray *filmshows = [NSMutableArray array];
        
        for (NSInteger t = 0; t < timeMatches.count; t++) {

            WTNFilmshow *newFilmshow;

            NSTextCheckingResult *timeMatch  = timeMatches[t];
            
            if ([timeMatch numberOfRanges] > 1) {
                
                NSString *time = [placeString substringWithRange:[timeMatch rangeAtIndex:1]];
                
                newFilmshow    = [[WTNFilmshow alloc] initWithCinema:cinema movie:self time:time];
                
                [filmshows addObject:newFilmshow];
                
//                // NSLog(@"time : %@ filmshow : %@", time, newFilmshow);
            }
            else{
                // NSLog(@"something wrong with place name");
            }
        }
        
        cinema.filmshows = filmshows;
        
        if (cinema) {
    
            [cinemas addObject:cinema];
        }

        
        // NSLog(@"filmshows : %@", cinema.filmshows);
    }
    
    self.cinemas = cinemas;
    
    // NSLog(@"cinemas : %@", self.cinemas);
}

#pragma mark -



#pragma mark -

- (void)updateRateAndPoster{

    dispatch_async(dispatch_queue_create("NEW_QUEUE", NULL), ^{
       
        [self updateRateAndPosterAsync];
        
    });
}


- (void)updateRateAndPosterAsync{
    
//http://www.kinopoisk.ru/index.php?first=no&kp_query=%D0%B1%D0%BB%D0%BE%D0%BD%D0%B4%D0%B8%D0%BD%D0%BA%D0%B0%20%D0%B2%20%D1%8D%D1%84%D0%B8%D1%80%D0%B5

//first=no&kp_query=22%20минуты
    
    NSDictionary *params = @{@"first"  : @"no",
                             @"kp_query" : self.name};
    
    __block  WTNMovie *__self = self;
    
    
    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:@"http://www.kinopoisk.ru/index.php"
                                                    andParams:params
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                                                   
                                                   if (status != 200) {
                                                       [__self updateRateAndPoster];
                                                       return;
                                                   }
                                                   
                                                   NSString *string = [[NSString alloc] initWithData:response encoding:NSWindowsCP1251StringEncoding];
                                                   
                                                   
                                                   if (!string) {
                                                       string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                                   }
                                                   
//                                                   NSLog(@"%s string : %@", __PRETTY_FUNCTION__, string);

                                                   dispatch_async(dispatch_queue_create("QUEUE", NULL),^{
                                                       
                                                       [__self handleUpdateRateAndPosterResponse:string];
                                                       
                                                   });
                                                   
                                               } andFailBlock:^(NSError *error) {
                                                   
                                                   // NSLog(@"%s %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
                                               }];
    [request start];

    
    
}

- (void)handleUpdateRateAndPosterResponse:(id)string{

   /*
//    NSTextCheckingResult *match = [st_rateRegex firstMatchInString:string
//                                                           options:0
//                                                             range:NSMakeRange(0, [string length])];
//    NSString *rateTargetString;
//    
//    if (match) {
//        
//        NSInteger rangesCount   = match.numberOfRanges;
//        
//        if (rangesCount > 1) {
//            
////            for (NSInteger i = 0; i < rangesCount; i++) {
////                // NSLog(@"range[%d] : %@", i, [string substringWithRange:[match rangeAtIndex:i]]);
////            }
//            
//            rateTargetString = [string substringWithRange:[match rangeAtIndex:1]];
//            
//            // NSLog(@"name : %@ rate : %@", self.name, rateTargetString);
//            
//            self.rate = rateTargetString;
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:MOVIE_RATE_UPDATED
//                                                                object:self
//                                                              userInfo:nil];
//        
//        }
//        else{
//            
//            // NSLog(@"ERROR : rangesCount == 0 %s line : %d", __PRETTY_FUNCTION__, __LINE__);
//        }
//    }
    */
    NSTextCheckingResult *match = [st_hrefRegex firstMatchInString:string
                                                           options:0
                                                             range:NSMakeRange(0, [string length])];
    
    NSString *pictureIDTargetString;
    
    if (match) {
        
        NSInteger rangesCount   = match.numberOfRanges;
        
        if (rangesCount > 0) {
            
//            for (NSInteger i = 0; i < rangesCount; i++) {
//                // NSLog(@"range[%d] : %@", i, [string substringWithRange:[match rangeAtIndex:i]]);
//            }
            
            pictureIDTargetString = [string substringWithRange:[match rangeAtIndex:1]];
            NSLog(@"            pictureIDTargetString = %@",            pictureIDTargetString);
            
            self.movieId = pictureIDTargetString;
            
            [self loadPosterForID:pictureIDTargetString];
            
        }
        else{
            
            // NSLog(@"ERROR : rangesCount == 0 %s line : %d", __PRETTY_FUNCTION__, __LINE__);
        }
    }
}

- (void)loadPosterForID:(NSString *)pictureIDTargetString{

    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:[NSString stringWithFormat:@"http://st.kp.yandex.net/images/film_big/%@.jpg", pictureIDTargetString]
                                                    andParams:nil
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                    
                                                   if (status != 200) {
                                                       
                                                       NSLog(@"gettin image status = %d", 200);
                                                       return;
                                                   }
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                   
                                                       self.poster = [UIImage imageWithData:response];
                                                       
                                                       [[WTNDataManager sharedManager] saveImageData:response withName:self.name];
                                                       
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:MOVIE_POSTER_UPDATED
                                                                                                           object:self];
                                                       
                                                   });
                                                   
                                                   
                                               } andFailBlock:^(NSError *error) {
                                                   
                                                   // NSLog(@"%s %d %@", __PRETTY_FUNCTION__, __LINE__, error);
                                               }];
    [request start];
}

#pragma mark -

- (NSString *)description{

    return self.name;
}

- (WTNFilmshow *)firstFilmShow{

    WTNFilmshow *targetFilmshow = nil;
    
    NSDate *currentDate = [NSDate date];
    NSDate *minDate     = [NSDate dateWithTimeIntervalSinceNow:86400];
    
    for (WTNCinema *cinema in self.cinemas) {
        
        WTNFilmshow *filmshow = cinema.firstFilmShow;
        NSDate      *date     = filmshow.fullDate;
        
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

- (WTNFilmshow *)nearestFilmshowByPlace{
    
    CLLocation         *currentLocation = [[WTNLocationsManager sharedManager] userLocation];
    WTNCinema          *targetCinema    = nil;
    WTNFilmshow        *targetFilmShow  = nil;
    CLLocationDistance distance         = CGFLOAT_MAX;
    
    for (WTNCinema *cinema in self.cinemas) {
        
        CLLocation         *location          = cinema.location;
        CLLocationDistance distanceToLocation = [location distanceFromLocation:currentLocation];
        
        if (distanceToLocation < distance) {
            
            WTNFilmshow *filmshow = cinema.firstFilmShow;
            
            if (filmshow){
                
                targetFilmShow = filmshow;
                targetCinema   = cinema;
                distance       = distanceToLocation;
            }
        }
    }

    return targetFilmShow;
}


#pragma mark - 

- (id)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        
        self.name             = [aDecoder decodeObjectForKey:@"name"];
        self.movieDescription = [aDecoder decodeObjectForKey:@"movie_description"];
        self.cinemas          = [aDecoder decodeObjectForKey:@"cinemas"];
        
//        for (WTNCinema *cinema in self.cinemas) {
//         
//            for (WTNFilmshow *filmshow in cinema.filmshows) {
//
//                filmshow.movie = self;
//                
//            }
//        }
        
        self.poster = [[WTNDataManager sharedManager] imageWithName:self.name];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeObject:self.name             forKey:@"name"];
    [aCoder encodeObject:self.movieDescription forKey:@"movie_description"];
    [aCoder encodeObject:self.cinemas          forKey:@"cinemas"];
}

@end
