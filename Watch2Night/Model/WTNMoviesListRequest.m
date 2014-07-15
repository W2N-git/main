//
//  WTNMoviesListRequest.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNMoviesListRequest.h"

#import "WTNMovie.h"
#import "WTNCity.h"
#import "WTNLocationsManager.h"
#import "WTNDataManager.h"
#import "NMURLRequest.h"

#import "WTNDefines.h"

static NSRegularExpression * st_step_1_regexp = nil;
static NSRegularExpression * st_step_2_regexp = nil;

@implementation WTNMoviesListRequest

+ (void)initialize{

    NSError *error   = NULL;
    st_step_1_regexp = [NSRegularExpression regularExpressionWithPattern:@"http:\\/\\/afisha\\.yandex\\.ru\\/[a-zA-Z]{0,3}\\/"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        // NSLog(@"%s line : %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }

    st_step_2_regexp = [NSRegularExpression regularExpressionWithPattern:@"<td>(?>[ ])*?<a href=\"((?>.)*?)\">((?>.)*?)<\\/a>(?>.)*?<\\/td>"
                                                                 options:NSRegularExpressionCaseInsensitive
                                                                   error:&error];
    if (error) {
        // NSLog(@"%s line : %d error : %@", __PRETTY_FUNCTION__, __LINE__, error);
    }
    
}

- (id)initWithCity:(WTNCity *)city
       finishBlock:(WTNURLMoviesRequestFinishBlock)finishBlock
         failBlock:(WTNURLRequestFailBlock)failBlock{

    if (self = [super init]) {
        
        self.city        = city;
        self.finishBlock = finishBlock;
        self.failBlock   = failBlock;
    }
    return self;
}

#pragma makr - STEP_1

// запрос у через гугл
// парсинг

- (void)start{
    
    WTNCity *listCity = [[WTNDataManager sharedManager] cityWithName:self.city.cityName];
    
    if (!listCity || !listCity.code) {
        
        ULog(@"%s listCity : %@",__PRETTY_FUNCTION__, listCity);
        
        return;
    }
    
    [self startStep2WithTargetURLString:[NSString stringWithFormat:@"http://m.afisha.yandex.ru/%@/events/", listCity.code]];
//    <a href="/msk/events/890748/">Новый Человек-паук: Высокое напряжение</a>
    return;
    /*
    __block WTNMoviesListRequest *__self = self;
    
//    https: //www.google.ru/search?q=site:http://afisha.yandex.ru/ москва кино&oq=site:http://afisha.yandex.ru/ москва кино&aqs=chrome..69i57j69i58.8915j0j7&sourceid=chrome&es_sm=119&ie=UTF-8
    
    NSDictionary *params = @{@"q"  : [NSString stringWithFormat:@"site:http://afisha.yandex.ru/ %@ кино", self.cityName],
                             @"oq" : [NSString stringWithFormat:@"site:http://afisha.yandex.ru/ %@ кино", self.cityName],
                             @"sourceid" :  @"chrome",
                             @"es_sm"    :  @"119",
                             @"ie"       :  @"UTF-8"};
    
    
    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:@"https://www.google.ru/search"
                                                    andParams:params
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                                             
                                                   
                                                   if (status != 200) {
                                                       
                                                       NSLog(@"%s repeat request", __PRETTY_FUNCTION__);
                                                       
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)),
                                                                      dispatch_get_main_queue(), ^{

                                                           [__self start];
                                                       });

                                                       
                                                       return;
                                                   }
//#warning ЧТО ДЕЛАТЬ ЕСТЬ КОДИРОВКА СМЕНИТСЯ
                                                   
                                                   NSString *htmlString = [[NSString alloc] initWithData:response
                                                                                                encoding:NSWindowsCP1251StringEncoding];
                                                   
                                                   [__self parseStep1_HTMLString:htmlString];
                                                   
                                               } andFailBlock:^(NSError *error) {
                                                   
                                                   // NSLog(@"%s error : %@", __PRETTY_FUNCTION__, error);

                                                   
                                                   if (self.failBlock) {
                                                       self.failBlock(error);
                                                   }
                                               }];
    [request start];
     */
}

- (void)parseStep1_HTMLString:(NSString *)string{

    
    NSTextCheckingResult *match = [st_step_1_regexp firstMatchInString:string
                                                               options:0
                                                                 range:NSMakeRange(0, [string length])];

    NSString *targetString;
    
    if (match) {

        NSInteger rangesCount   = match.numberOfRanges;
        
        if (rangesCount > 0) {
            
            targetString = [string substringWithRange:[match rangeAtIndex:0]];
            
            targetString = [targetString stringByReplacingOccurrencesOfString:@"http://afisha" withString:@"http://m.afisha"];
            
            [self startStep2WithTargetURLString:[NSString stringWithFormat:@"%@events/", targetString]];
        }
        else{
            
            // NSLog(@"ERROR : rangesCount == 0 %s line : %d", __PRETTY_FUNCTION__, __LINE__);
        }
    }
}


#pragma mark - STEP_2

- (void)startStep2WithTargetURLString:(NSString *)URLString{
    
    NSDictionary *params  = @{@"category" : @"cinema",
                              @"limit"    : @"20"};
    
    __block WTNMoviesListRequest *__self      = self;
    __block NSString             *__URLString = URLString;
    
    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:URLString
                                                    andParams:params
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                                                   
                                                   if (status != 200) {

                                                       NSLog(@"%s repeat request", __PRETTY_FUNCTION__);

                                                       [__self startStep2WithTargetURLString:__URLString];
                                                       return;
                                                   }
                                                   
                                                   NSString *htmlString = [[NSString alloc] initWithData:response
                                                                                                encoding:NSUTF8StringEncoding];

                                                   
                                                   [__self parseStep2_HTMLString:htmlString];
                                                   
                                               } andFailBlock:^(NSError *error) {

                                                   // NSLog(@"%s error : %@", __PRETTY_FUNCTION__, error);
                                                   
                                                   if (self.failBlock) {
                                                       self.failBlock(error);
                                                   }
                                               }];
    
    [request start];
}

// запрос страницы сайта
// парсинг

- (void)parseStep2_HTMLString:(NSString *)string{
    
//  // NSLog(@"string :%@", string);
    
    NSArray *matches = [st_step_2_regexp matchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
    
    NSMutableArray *newMovies = [NSMutableArray array];
    
    for (NSInteger i = 0; i < matches.count; i++){ //(NSTextCheckingResult *match in matches) {
        
        NSTextCheckingResult *match                 = matches[i];
        NSInteger             rangesCount           = [match numberOfRanges];
        NSMutableArray       *movieStringComponents = [NSMutableArray array];
        
        
        for (NSInteger i = 0; i < rangesCount; i++) {
            
            [movieStringComponents addObject:[string substringWithRange:[match rangeAtIndex:i]]];
        }
        
        // NSLog(@"\n\n\n\nmovie[%d] : %@", (int)i, [movieStringComponents componentsJoinedByString:@"____"]);
        
        if (rangesCount > 1) {
            
            WTNMovie *movie         = [WTNMovie new];
            movie.name              = [string substringWithRange:[match rangeAtIndex:2]];
            
            NSString *pathComponent = [string substringWithRange:[match rangeAtIndex:1]];
            movie.hReference        = [@"http://m.afisha.yandex.ru/" stringByAppendingPathComponent:pathComponent];

            [newMovies addObject:movie];
            
//            if (newMovies.count == 2) {
//
//#warning !!!
//                
//                break;
//            }
        }
    }
    
//    [newMovies[0] updateCinemasInfo];

    if (self.finishBlock) {
        self.finishBlock(newMovies);
    }
}

@end
