//
//  WTNLocationsManager.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//


// Класс должен отслеживать местоположение пользователя, определять название города, подгружать список кинотеатров, работать с расстояниями

#import <Foundation/Foundation.h>

@class WTNCity;

@interface WTNLocationsManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic)         BOOL       locationInfoValid;
@property (nonatomic, strong) CLLocation *userLocation;

@property (nonatomic, strong) CLLocation *userChoosedLocation;

@property (nonatomic, strong) WTNCity    *currentCity;
@property (nonatomic, strong) WTNCity    *userChoosedCity;

- (void)prepareForWork;

- (void)getLocationInfo;

@end
