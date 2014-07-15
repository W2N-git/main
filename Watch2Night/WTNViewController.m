//
//  WTNViewController.m
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNViewController.h"

#import "WTNTableViewController2_TEMP.h"


#import "WTNDefines.h"

#import "WTNLocationsManager.h"
#import "Model/WTNDataManager.h"

#import "Model/WTNMovie.h"

#import "WTNMovieTableViewCell_TEMP.h"


@interface WTNViewController ()

@end

@implementation WTNViewController{

    NSArray *_movies;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    WTNMovieTableViewCell_TEMP *cell = [tableView dequeueReusableCellWithIdentifier:@"WTNMovieTableViewCell_TEMP"];
    
    cell.movie = _movies[indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"showFilmShows"]) {
        WTNTableViewController2_TEMP *vc = segue.destinationViewController;
        vc.movie = _movies[[[self.tableView indexPathForSelectedRow] row]];
    }
}

@end
