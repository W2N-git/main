//
//  WTNMapViewController.h
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface WTNMapViewController : UIViewController

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
