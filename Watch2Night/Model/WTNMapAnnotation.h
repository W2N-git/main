//
//  WTNMapAnnotation.h
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface WTNMapAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
