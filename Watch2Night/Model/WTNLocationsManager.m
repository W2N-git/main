//
//  WTNLocationsManager.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNLocationsManager.h"
#import "WTNDataManager.h"

#import "WTNDefines.h"

#import "WTNCity.h"




@interface WTNLocationsManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *cllManager;

@end



@implementation WTNLocationsManager

+ (instancetype)sharedManager{

    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


#pragma mark - Prepare for work

- (void)prepareForWork{

    [self preloadUserChoosedLocation];
    [self preloadUserChoosedCity];
}


- (void)preloadUserChoosedLocation{


    NSData *locationData = [UserDefaults objectForKey:@"user_choosed_location"];
    
    CLLocation *location = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    
    if (!location) {
        
        location = [[CLLocation alloc] initWithLatitude:MINSK_LOCATION_COORDINATE_2D.latitude
                                              longitude:MINSK_LOCATION_COORDINATE_2D.longitude];
    }

    _userChoosedLocation = location;
    
    [self saveUserChoosedLocation];
}


- (void)preloadUserChoosedCity{

    
    NSData *userChoosedCityData = [UserDefaults objectForKey:@"user_choosed_city"];
    
    WTNCity *userChoosedCity = [NSKeyedUnarchiver unarchiveObjectWithData:userChoosedCityData];
        
    if (!userChoosedCity) {
        
        userChoosedCity             = [WTNCity new];
        userChoosedCity.cityName    = @"Минск";
        userChoosedCity.countryName = @"Беларусь";
        userChoosedCity.location    = _userChoosedLocation;
        
    }
    _userChoosedCity = userChoosedCity;
    
    [self saveUserChoosedCity];
}


#pragma mark -

- (void)saveUserChoosedLocation{
    
    NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:self.userChoosedLocation];
    
    [UserDefaults setObject:locationData forKey:@"user_choosed_location"];
}

- (void)saveUserChoosedCity{
    
    NSData *cityData = [NSKeyedArchiver archivedDataWithRootObject:self.userChoosedCity];
    
    [UserDefaults setObject:cityData     forKey:@"user_choosed_city"];
}

#pragma mark -


- (void)getLocationInfo{

    [[NSNotificationCenter defaultCenter] addObserverForName:CITIES_LIST_LOADED
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                     
                                                      
                                                      if ([CLLocationManager locationServicesEnabled]) {
                                                          
                                                          self.locationInfoValid     = YES;
                                                          
                                                          _cllManager                = [CLLocationManager new];
                                                          
                                                          _cllManager.delegate       = self;
                                                          _cllManager.distanceFilter = 100.0;
                                                          
                                                          [_cllManager startMonitoringSignificantLocationChanges];
                                                      }
                                                      else{
                                                          
                                                          self.locationInfoValid = NO;
                                                          
                                                          ULog(@"Location services disabled");
                                                      }
                                                  }];
}


#pragma mark - Core Location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

     NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (NSInteger i = 0; i < locations.count; i++) {
        // NSLog(@"location[%d] = %@", i, locations[i]);
    }
    
    self.userLocation    = locations[0];
  
    if (!_userChoosedLocation) {
        _userChoosedLocation = self.userLocation;
        [self saveUserChoosedLocation];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOCATION_UPDATED object:nil];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    
    
    [geocoder reverseGeocodeLocation:self.userLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {

                       if (error){

                           // NSLog(@"Geocode failed with error: %@", error);

                           ULog(@"City geocode failed with error: %@", error);

                           return;

                       }
                       
                       // NSLog(@"placemarks : %@", placemarks);
                       
                       for (int i = 0; i < placemarks.count; i++) {
                           // NSLog(@"placemarks[%d] : %@", i, placemarks[i]);
                       }

                       WTNCity *newCity = [[WTNCity alloc] initWithPlacemark:placemarks[0]];
                       
                       if (!self.currentCity || ![newCity isEqual:self.currentCity]) {
                           
                           self.currentCity = newCity;
                           
                           
                           if (!self.userChoosedCity) {
                               self.userChoosedCity = newCity;
                               [self saveUserChoosedCity];
                           }
                           
                           
                           
                           [[NSNotificationCenter defaultCenter] postNotificationName:USER_CITY_UPDATED
                                                                               object:nil];
                       }
                   }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

     NSLog(@"%s error : %@", __PRETTY_FUNCTION__, error);

    ULog(@"locationManager failed with error: %@", error);

}


#pragma mark -


- (void)setUserChoosedLocation:(CLLocation *)userChoosedLocation{

    NSLog(@"%s", __PRETTY_FUNCTION__);

    
    _userChoosedLocation = userChoosedLocation;
    [self saveUserChoosedLocation];
    
    [[CLGeocoder new] reverseGeocodeLocation:userChoosedLocation
                           completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                           if (error){
                               
                               // NSLog();
                               
                               ULog(@"User choosed city Geocode failed with error: %@", error);
                               
                               return;
                               
                           }
                           
                           // NSLog(@"placemarks : %@", placemarks);
                           
                           for (int i = 0; i < placemarks.count; i++) {
                                NSLog(@"placemarks[%d] : %@", i, placemarks[i]);
                           }
                           
                           WTNCity *newCity = [[WTNCity alloc] initWithPlacemark:placemarks[0]];
                           
                           if (!self.userChoosedCity || ![newCity isEqual:self.userChoosedCity]) {
                               
                               self.userChoosedCity = newCity;
                               [self saveUserChoosedCity];
                               
                               [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHOOSED_CITY_UPDATED
                                                                                   object:nil];
                           }
                   }];
}

@end
