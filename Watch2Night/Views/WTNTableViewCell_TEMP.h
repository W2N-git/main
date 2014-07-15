//
//  WTNTableViewCell_TEMP.h
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WTNMovie;

@class WTNCinema;

@interface WTNTableViewCell_TEMP : UITableViewCell

@property (nonatomic, strong) WTNMovie *movie;

@property (nonatomic, strong) WTNCinema *cinema;

@property (nonatomic, weak) IBOutlet UILabel *times;

@end
