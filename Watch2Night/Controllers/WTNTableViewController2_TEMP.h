//
//  WTNTableViewController2_TEMP.h
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTNMovie;

@interface WTNTableViewController2_TEMP : UITableViewController

@property (nonatomic, weak) IBOutlet UILabel *nearestFilmshowCinemaName;
@property (nonatomic, weak) IBOutlet UILabel *nearestFilmshowTime;

@property (nonatomic, weak) IBOutlet UILabel *nearestCinemaName;
@property (nonatomic, weak) IBOutlet UILabel *nearestCinemaFilmshowTime;


@property (nonatomic, strong) WTNMovie *movie;

@end
