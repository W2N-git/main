//
//  WTNMapAnnotation.m
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNMapAnnotation.h"

@implementation WTNMapAnnotation

@synthesize title;
@synthesize subtitle;
@synthesize coordinate = _coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate{

    if (self = [super init]) {
        
        _coordinate = coordinate;
        
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate{

    return _coordinate;
}

@end
