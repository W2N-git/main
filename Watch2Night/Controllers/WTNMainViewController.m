//
//  WTNMainViewController.m
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNMainViewController.h"

#import "WTNDefines.h"
#import "WTNLocationsManager.h"
#import "WTNDataManager.h"
#import "WTNMovieTableViewController.h"

#import "WTNCity.h"




@interface WTNMainViewController ()

@end

@implementation WTNMainViewController{

    __strong id _observer;
    __strong id _observer2;
    
    NSArray *_movieControllers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WTNCity *city = [[WTNLocationsManager sharedManager] userChoosedCity];
    
    [self.mapButton setTitle:city.cityName forState:UIControlStateNormal];
    
    [self updateScrollView];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:USER_CHOOSED_CITY_UPDATED
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                     
                                                      WTNCity *city = [[WTNLocationsManager sharedManager] userChoosedCity];
                                                      
                                                      [self.mapButton setTitle:city.cityName forState:UIControlStateNormal];
                                                      
                                                      [self updateScrollView];
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:CURRENT_DATE_UPDATED
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      WTNCity *city = [[WTNLocationsManager sharedManager] userChoosedCity];
                                                      
                                                      [self.mapButton setTitle:city.cityName forState:UIControlStateNormal];
                                                      
                                                      [self updateScrollView];
                                                  }];

    
    [[NSNotificationCenter defaultCenter] addObserverForName:MOVIE_LIST_LOADED
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
//                                                      WTNCity *city = [[WTNLocationsManager sharedManager] userChoosedCity];
//                                                      
//                                                      [self.mapButton setTitle:city.cityName forState:UIControlStateNormal];
                                                      
                                                      [self updateScrollView];
                                                  }];
    
    [[WTNLocationsManager sharedManager] getLocationInfo];
    [[WTNDataManager      sharedManager] getCitiesFromPage];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)mapButtonPressed:(id)sender{
    
    UINavigationController *vc =  [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewParentViewController"];
    
    vc.view.frame = CGRectMake(0.0, 50.0, vc.view.frame.size.width, vc.view.frame.size.height);
    vc.view.alpha = 0.0;

    [self      addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [UIView animateWithDuration:0.16
     
                     animations:^{
                         
                         vc.view.frame = self.view.bounds;
                         vc.view.alpha = 1.0;

                     } completion:^(BOOL finished) {
                         
                         [vc didMoveToParentViewController:self];
                     }];
}


- (void)hideMapViewController:(UIViewController *)vc{
    
    [vc willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.16
                     animations:^{
                         
                         vc.view.frame = CGRectMake(0.0, 50.0, vc.view.frame.size.width, vc.view.frame.size.height);
                         
                         vc.view.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [vc.view removeFromSuperview];
                         [vc      removeFromParentViewController];
                     }];
}


#pragma mark - UIScrollView


- (void)updateScrollView{

    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         [self.mainScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
                         
                     } completion:^(BOOL finished) {
                        
                         [self updateScrollViewCompletion];
                     }];
}

- (void)updateScrollViewCompletion{

    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSArray *movies = [[WTNDataManager sharedManager] movies];
    
    for (UIViewController *vc in _movieControllers) {
    
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc      removeFromParentViewController];
    }

    
    NSMutableArray *movieControllers = [NSMutableArray array];
    
    for (NSInteger i = 0; i < movies.count; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * self.view.frame.size.width,
                                                                0.0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height)];
        
        view.backgroundColor = i%2==0 ? [UIColor redColor] : [UIColor greenColor];
        
        [self.mainScrollView addSubview:view];
        
        
        
        WTNMovieTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WTNMovieTableViewController"];
        
        vc.view.backgroundColor = [UIColor redColor];
        
        vc.view.frame = CGRectMake(i * self.view.frame.size.width,
                                   0.0,
                                   self.view.frame.size.width,
                                   self.view.frame.size.height);
        
        [self addChildViewController:vc];
        [self.mainScrollView addSubview:vc.view];
        
        [vc didMoveToParentViewController:self];
    
        vc.movie                        = movies[i];
        
        [movieControllers addObject:vc];
    }
    
    _movieControllers = movieControllers;
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * movies.count,
                                                 self.view.frame.size.height);
}

@end
