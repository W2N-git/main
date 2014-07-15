//
//  WTNMovieTableViewController.h
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTNMovie;

@interface WTNMovieTableViewController : UITableViewController

@property (nonatomic, strong) WTNMovie *movie;

@property (nonatomic, weak)   IBOutlet UILabel     *movieNameLabel_temp;
@property (nonatomic, weak)   IBOutlet UIImageView *moviePosterImageView;


@end
