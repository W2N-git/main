//
//  WTNTableViewController2_TEMP.m
//  Watch2Night
//
//  Created by qw on 12.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import "WTNTableViewController2_TEMP.h"

#import "WTNMovie.h"

#import "WTNCinema.h"

#import "WTNFilmshow.h"

#import "WTNTableViewCell_TEMP.h"



@interface WTNTableViewController2_TEMP ()

@end

@implementation WTNTableViewController2_TEMP

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDate *date = [NSDate date];
    
    WTNFilmshow *nearestFilmshow        = self.movie.firstFilmShow;
    
    NSLog(@"nearestFilmshow search time : %f", [[NSDate date] timeIntervalSinceDate:date]);
    
    
    self.nearestFilmshowCinemaName.text = nearestFilmshow.cinema.name;
    self.nearestFilmshowTime.text       = nearestFilmshow.time;
    
    date = [NSDate date];
    
    WTNFilmshow *nearestFilmshowByPlace = self.movie.nearestFilmshowByPlace;
    
    NSLog(@"nearestFilmshowByPlace search time : %f", [[NSDate date] timeIntervalSinceDate:date]);
    
    self.nearestCinemaName.text         = nearestFilmshowByPlace.cinema.name;
    self.nearestCinemaFilmshowTime.text = nearestFilmshowByPlace.time;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.movie.cinemas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    return [(WTNCinema *)self.movie.cinemas[section] name];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WTNTableViewCell_TEMP *cell = [tableView dequeueReusableCellWithIdentifier:@"WTNTableViewCell_TEMP" forIndexPath:indexPath];
    
    cell.cinema                 = self.movie.cinemas[indexPath.section];

    return cell;
}

@end
