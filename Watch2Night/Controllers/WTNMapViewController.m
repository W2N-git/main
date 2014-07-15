//
//  WTNMapViewController.m
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNMapViewController.h"

#import "WTNLocationsManager.h"

#import "WTNMainViewController.h"

#import "WTNMapAnnotation.h"

@interface WTNMapViewController () <MKMapViewDelegate>

@end

@implementation WTNMapViewController{

    
    CLLocationCoordinate2D _coordinate;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CLLocation *userChoosedLocation = [[WTNLocationsManager sharedManager] userChoosedLocation];
    
    self.mapView.delegate = self;
    
    if (userChoosedLocation) {
        
        [self.mapView addAnnotation:[[WTNMapAnnotation alloc] initWithCoordinate:userChoosedLocation.coordinate]];
            
        self.mapView.region = MKCoordinateRegionMakeWithDistance(userChoosedLocation.coordinate, 500, 500);
    }
    else{
    
        CLLocation *location = [[WTNLocationsManager sharedManager] userLocation];
        
        if (location) {
            
            [self.mapView addAnnotation:[[WTNMapAnnotation alloc] initWithCoordinate:location.coordinate]];
            
            self.mapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
        }
    
    }
    
 
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(longPressAction:)];
    
    
//    longTap.minimumPressDuration = 1.0;
    
    [self.view addGestureRecognizer:longTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)longPressAction:(id)sender{

    if ([(UILongPressGestureRecognizer *)sender state] == UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint tapPoint = [sender locationInView:self.view];

    _coordinate = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotation:[[WTNMapAnnotation alloc] initWithCoordinate:_coordinate]];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{

    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    }
    else {
        pin.annotation = annotation;
    }
    
    pin.animatesDrop = YES;
//    pin.draggable = YES;
    
    return pin;
}

#pragma mark -

- (IBAction)hideButtonPressed:(id)sender{
    
    WTNMainViewController *vc = (WTNMainViewController *)self.navigationController.parentViewController;
    
    [vc hideMapViewController:self.navigationController];
}

- (void)cancelButtonPressed:(id)sender{

//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    WTNMainViewController *vc = (WTNMainViewController *)self.navigationController.parentViewController;
    
    [vc hideMapViewController:self.navigationController];
}

- (void)doneButtonPressed:(id)sender{

//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[WTNLocationsManager sharedManager] setUserChoosedLocation:[[CLLocation alloc] initWithLatitude:_coordinate.latitude
                                                                                           longitude:_coordinate.longitude]];
    
    WTNMainViewController *vc = (WTNMainViewController *)self.navigationController.parentViewController;
        
    [vc hideMapViewController:self.navigationController];
}


@end
