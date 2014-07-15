//
//  WTNDataManager.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

// класс должен работать со всеми основными запросами, обрабатывать информацию, сохраять ее

#import "WTNDataManager.h"
#import "WTNLocationsManager.h"

#import "WTNDefines.h"

#import "WTNCity.h"
#import "WTNCinema.h"
#import "WTNMovie.h"

#import "WTNMoviesListRequest.h"
#import "NMURLRequest.h"

#import "NSDate+time.h"

@interface  WTNDataManager ()

@property (nonatomic, strong) NSTimer *dateCheckerTimer;

@end


@implementation WTNDataManager

+ (instancetype)sharedManager{
  
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


#pragma mark - Preparing at start of work

- (void)prepareForWork{

    [self startListenNotifications];
    
    [self preloadDate];

    [self loadCitiesLocally];
    [self loadCinemasLocally];
    [self loadMoviesLocally];
}

- (void)startListenNotifications{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stepToLoadCinemas)
                                                 name:CITIES_LIST_LOADED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stepToLoadCinemas)
                                                 name:USER_CHOOSED_CITY_UPDATED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:USER_CHOOSED_CITY_UPDATED
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                     
                                                      self.cinemas = nil;
                                                      
                                                      [self stepToLoadCinemas];
                                                  }];
}

- (void)preloadDate{
    
    [self checkDate];
    [self startCheckingDate];
}





#pragma mark - 
#pragma mark - Check date

- (void)startCheckingDate{

    self.dateCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                             target:self
                                                           selector:@selector(checkDate)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)checkDate{

#warning TODO : если дата изменилась - перезагрузить список фильмов \
                каждую минуту обновлять информацию по фильмам (список кинотеатров для показа, текущий ближайший сеанс)
    
    self.lastDate = [UserDefaults objectForKey:@"last_date"];
    
    if (!self.lastDate) {
        
        self.lastDate = [NSDate dateWithHours:6 minutes:0];
        [self dateUpdated];
    }
    else if ([[NSDate date] timeIntervalSinceDate:self.lastDate] > 86400){
        
        self.lastDate = [NSDate dateWithHours:6 minutes:0];
        [self dateUpdated];
    }
    
    [UserDefaults setObject:self.lastDate forKey:@"last_date"];
}

- (void)dateUpdated{

    [[NSNotificationCenter defaultCenter] postNotificationName:CURRENT_DATE_UPDATED
                                                        object:nil];
}


#pragma mark - 
#pragma mark - City


- (void)userChoosedCityUpdated{
    
    [self getCimenasFromPage];
}

#pragma mark - 
#pragma mark - Cities from page


- (void)loadCitiesLocally{
    
    self.cities = [NSKeyedUnarchiver unarchiveObjectWithFile:FileFromDocPath(@"cities")];
}


- (void)getCitiesFromPage{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    __unsafe_unretained WTNDataManager *__self = self;
    
    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:@"http://afisha.yandex.ru/change_city/"
                                                    andParams:nil
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                                                   
                                                   if (status != 200) {
                                                       [__self  getCitiesFromPage];
                                                       return;
                                                   }
                                                   
                                                   [__self handeleGetCitiesFromPage:response];
                                                   
                                               } andFailBlock:^(NSError *error) {
                                                   
                                                   NSLog(@"%s error : %@", __PRETTY_FUNCTION__, error);
                                                   
                                               }];
    
    [request start];

}


- (void)handeleGetCitiesFromPage:(id)response{

    NSError *error = nil;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"<li>(?>.)*?\"\\/([a-z]{3})\\/\">((?>.)*?)<\\/a>(?>\\s)*?<\\/li>"
                                                                      options:0
                                                                        error:&error];
    
    if (error) {
        NSLog(@"%s error : %@", __PRETTY_FUNCTION__, error);
    }
    
    
    NSString *string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    
    NSArray *matches = [regex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, string.length)];
    
    
    NSMutableArray *cities = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        
        NSInteger rangesCount = [match numberOfRanges];
        
        if (rangesCount > 2) {
            
            WTNCity *newCity = [WTNCity new];
            
            newCity.code     = [string substringWithRange:[match rangeAtIndex:1]];
            newCity.cityName = [string substringWithRange:[match rangeAtIndex:2]];
            
            NSLog(@"%@ %@", newCity.code, newCity.cityName);
            
            [cities addObject: newCity];
        }
    }
    
    self.cities = cities;
    
    [self saveCities];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CITIES_LIST_LOADED object:nil];
}

- (void)saveCities{

    [NSKeyedArchiver archiveRootObject:self.cities toFile:FileFromDocPath(@"cities")];
}

- (WTNCity *)cityWithName:(NSString *)name{

    for (WTNCity *city in self.cities) {
        if ([city.cityName isEqualToString:name]) {
            return city;
        }
    }
    
    return nil;
}




#pragma mark -
#pragma mark - cinemas

- (void)loadCinemasLocally{

    self.cinemas = [NSKeyedUnarchiver unarchiveObjectWithFile:FileFromDocPath(@"cinemas")];
}

- (void)stepToLoadCinemas{
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.cities &&  [[WTNLocationsManager sharedManager] userChoosedCity]) {
        
        if (!self.cinemas) {
            NSLog(@"will load cinemas");
        
            
            [[NSNotificationCenter defaultCenter] addObserverForName:CINEMAS_LIST_LOADED
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              
                                                              [self getMovies];
                                                          }];
            [self getCimenasFromPage];
        }
    }
}


- (void)getCimenasFromPage{

    NSLog(@"%s", __PRETTY_FUNCTION__);

    /*
//     <tr class="place place_id_10184" id="f">  <td>    <a class="place_title" href="/msk/places/10184/">35 мм</a>  </td>  <td>    <div class="geo">  <span class="latitude">55.7636750</span>,  <span class="longitude">37.6540080</span>  </div>        <img src="/media/desktop/img/arr_addr.gif" class="arr_addr"/>  <a href="http://maps.yandex.ru/?ol=biz&oid=1064847172">ул. Покровка, 47/24</a>      </td>    <td>Красные Ворота, Курская</td>    </tr>
//    только название (?><tr class="place place_id_(?>.)*?>(?>.)*?<a class(?>.)*?>((?>.)*?)<\/a>(?>.)*?<\/tr>)
//    все сразу (?><tr(?>\s)*?class(?>\s)*?=(?>\s)*?"place(?>\s)*?place_id_(?>.)*?>(?>.)*?<a(?>\s)*?class(?>.)*?>(?>\s)*?((?>.)*?)(?>\s)*?<\/a>(?>.)*?<span(?>\s)*?class(?>\s)*?=(?>\s)*?"latitude">(?>\s)*?([0-9]{0,2}\.[0-9]*?)(?>\s)*?<\/span>(?>.)*?<span(?>\s)*?class(?>\s)*?=(?>\s)*?"longitude">(?>\s)*?([0-9]{0,2}\.[0-9]*?)(?>\s)*?<\/span>(?>.)*?<a href=(?>.)*?>((?>.)*?)<\/a>(?>.)*?<td>(?>\s)*?((?>.)*?)(?>\s)*?<\/td>(?>\s)*?<\/tr>)

//    http://afisha.yandex.ru/msk/places/?category=cinema&limit=1000
    
     */
    
    __unsafe_unretained WTNDataManager *__self = self;
    
    WTNCity *currentCity = [[WTNLocationsManager sharedManager] userChoosedCity];
    

    WTNCity *listCity = [self cityWithName:currentCity.cityName];
    
    
    NMURLRequest *request = [[NMURLRequest alloc] initWithUrl:[NSString stringWithFormat:@"http://afisha.yandex.ru/%@/places", listCity.code]
                                                    andParams:@{@"category" : @"cinema", @"limit" : @"1000"}
                                                andHttpMethod:kNMURLRequestHttpMethodGet
                                             andParsingEngine:kNMURLRequestParsingEngineRawData
                                               andFinishBlock:^(id response, NSInteger status) {
                                                   
                                                   if (status != 200) {
                                                       [__self  getCimenasFromPage];
                                                       return;
                                                   }
                                                   
                                                   [__self handleGetCimenasFromPageResponse:response];
                                                   
                                               } andFailBlock:^(NSError *error) {
                                                   // NSLog(@"%s error : %@", __PRETTY_FUNCTION__, error);
                                               }];
    
    [request start];
}

- (void)handleGetCimenasFromPageResponse:(id)response{

    NSString            *string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSError             *error  = nil;
    
    NSRegularExpression *regex  = [[NSRegularExpression alloc] initWithPattern:@"(?><tr(?>\\s)*?class(?>\\s)*?=(?>\\s)*?\"place(?>\\s)*?place_id_(?>.)*?>(?>.)*?<a(?>\\s)*?class(?>.)*?>(?>\\s)*?((?>.)*?)(?>\\s)*?<\\/a>(?>.)*?<span(?>\\s)*?class(?>\\s)*?=(?>\\s)*?\"latitude\">(?>\\s)*?([0-9]{0,2}\\.[0-9]*?)(?>\\s)*?<\\/span>(?>.)*?<span(?>\\s)*?class(?>\\s)*?=(?>\\s)*?\"longitude\">(?>\\s)*?([0-9]{0,2}\\.[0-9]*?)(?>\\s)*?<\\/span>(?>.)*?<a href=(?>.)*?>((?>.)*?)<\\/a>(?>.)*?<td>(?>\\s)*?((?>.)*?)(?>\\s)*?<\\/td>(?>\\s)*?<\\/tr>)"
                                                                      options:0
                                                                        error:&error];

    NSArray *matches = [regex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, [string length])];
    
    NSMutableArray *cinemas = [NSMutableArray array];
    
    for (NSInteger m = 0; m < matches.count; m++) {
    
        NSTextCheckingResult *match      = matches[m];
        NSInteger            rangesCount = [match          numberOfRanges];
        NSMutableArray       *components = [NSMutableArray array];
        
        for (NSInteger i = 1; i < rangesCount; i++) {
            
            [components addObject:[string substringWithRange:[match rangeAtIndex:i]]];
        }
        
        // NSLog(@"cinema[%d] : %@", m, [components  componentsJoinedByString:@"___"]);
        
        WTNCinema *cinema = [WTNCinema new];
        cinema.name       = components[0];
        cinema.location   = [[CLLocation alloc] initWithLatitude:[components[1] doubleValue] longitude:[components[2] doubleValue]];
        cinema.address    = components[3];
        
        [cinemas addObject:cinema];
#warning TODO: добавить в объект WTNCinema метро (или можно получить при получении сеансов)
    }
    self.cinemas = cinemas;
    
    [self saveCinemas];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CINEMAS_LIST_LOADED
                                                        object:nil];
}


- (void)saveCinemas{
    
    [NSKeyedArchiver archiveRootObject:self.cinemas toFile:FileFromDocPath(@"cinemas")];
}

#pragma mark - movies data

- (void)loadMoviesLocally{

    self.movies = [NSKeyedUnarchiver unarchiveObjectWithFile:FileFromDocPath(@"movies")];
}

- (void)getMovies{

     NSLog(@"%s", __PRETTY_FUNCTION__);
    
    __unsafe_unretained WTNDataManager *__self = self;
    
    WTNMoviesListRequest *request = [[WTNMoviesListRequest alloc] initWithCity:[[WTNLocationsManager sharedManager] userChoosedCity]
                                                                   finishBlock:^(NSArray *movies) {
                                                                       
                                                                       __self.movies = movies;
                                                                       
                                                                       NSLog(@"movies : %@", movies);
                                                                       
                                                                       [self saveMovies];
                                                                       
                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:MOVIE_LIST_LOADED
                                                                                                                           object:nil];
                                                                       
                                                                   } failBlock:^(NSError *error) {
                                                                       
                                                                       NSLog(@"error : %@", error);
                                                                       
                                                                       ULog(@"get movies error : %@", error);
                                                                   }];
    [request start];
}

- (void)saveMovies{

    [NSKeyedArchiver archiveRootObject:self.movies toFile:FileFromDocPath(@"movies")];
}

#pragma mark - 

- (WTNCinema *)cinemaWithName:(NSString *)name{

    if (!name) {
        // NSLog(@"nil cinema name");
        return nil;
    }
    
    __block WTNCinema *targetCinema = nil;
    
    [self.cinemas enumerateObjectsUsingBlock:^(WTNCinema *obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj.name isEqualToString:name]) {
            targetCinema = obj;
            *stop        = YES;
        }
    }];
    
    if (!targetCinema) {
         NSLog(@"no cinema with name : %@", name);
    }
    
    return targetCinema;
}




#pragma mark -

- (void)saveImageData:(NSData *)data withName:(NSString *)name{

    NSString *filename = [NSString stringWithFormat:@"%@.png", name];
    
    [data writeToFile:FileFromDocPath(filename)
           atomically:YES];
}

- (UIImage *)imageWithName:(NSString *)name{

    NSString *filename = [NSString stringWithFormat:@"%@.png", name];
    
    return [UIImage imageWithContentsOfFile:FileFromDocPath(filename)];
}

@end
