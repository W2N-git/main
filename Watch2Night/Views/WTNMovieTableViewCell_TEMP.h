//
//  WTNMovieTableViewCell_TEMP.h
//  Watch2Night
//
//  Created by qw on 11.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTNMovie;

@interface WTNMovieTableViewCell_TEMP : UITableViewCell


@property (nonatomic, weak) IBOutlet UIImageView *posterImageView;
@property (nonatomic, weak) IBOutlet UILabel     *movieNameLabel;
@property (nonatomic, weak) IBOutlet UILabel     *rateLabel;


@property (nonatomic, strong) WTNMovie *movie;

@end
