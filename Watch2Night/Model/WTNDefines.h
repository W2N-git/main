//
//  WTNDefines.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#ifndef Watch2Night_WTNDefines_h
#define Watch2Night_WTNDefines_h


#pragma mark - Macros

#define UserDefaults              [NSUserDefaults standardUserDefaults]

#define DocPath                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)    objectAtIndex:0]

//#define FileFromDocPath(filepath) [NSHomeDirectory() stringByAppendingPathComponent:(filepath)]
#define FileFromDocPath(filepath) [DocPath stringByAppendingPathComponent:filepath]

//#define RemoveFileFromDocPath(path) [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:(path)] error:nil]
#define RemoveFileFromDocPath(path) [[NSFileManager defaultManager] removeItemAtPath:[DocPath stringByAppendingPathComponent:path] error:nil]


#pragma mark - Macros Logs

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#define NSLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#ifdef DEBUG
#define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#define ULog(...)
#endif

#define UA_rgba(r,g,b,a)				[UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UA_rgb(r,g,b)					UA_rgba(r, g, b, 1.0f)



#pragma mark -
#pragma mark - Api Keys

#define GOOGLE_PLACES_API_KEY @"AIzaSyAmK75TZAkRikJVbK21r_IXxp6571j9l5k"
#define YANDEX_MAPS_API_KEY   @"ALIIblMBAAAAMYhyGQIAdkyAh4TfZQe2VlBmY6KB0ih-cWoAAAAAAAAAAAAEn4TZ5IKb6PitK0haUR5-smEk5A=="


#pragma mark - Preloads
//27.554914, 53.906077
#define MINSK_LOCATION_COORDINATE_2D CLLocationCoordinate2DMake(53.906077, 27.554914)



#pragma mark - Notification Keys

#define CURRENT_DATE_UPDATED  @"CURRENT_DATE_UPDATED"
#define MINUTE_PASSED         @"MINUTE_PASSED"


#define CITIES_LIST_LOADED    @"CITIES_LIST_LOADED"

#define USER_LOCATION_UPDATED       @"USER_LOCATION_UPDATED"
#define USER_CITY_UPDATED           @"USER_CITY_UPDATED"
#define USER_CHOOSED_CITY_UPDATED   @"USER_CHOOSED_CITY_UPDATED"

#define CINEMAS_LIST_LOADED         @"CINEMAS_LIST_LOADED"

#define MOVIE_LIST_LOADED           @"MOVIE_LIST_LOADED"

#define MOVIE_CINEMA_INFOS_UPDATED  @"MOVIE_CINEMA_INFOS_UPDATED"
#define MOVIE_POSTER_UPDATED        @"MOVIE_POSTER_UPDATED"
#define MOVIE_RATE_UPDATED          @"MOVIE_RATE_UPDATED"

#endif
