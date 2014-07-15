//
//  WTNMoviesListRequest.h
//  Watch2Night
//
//  Created by qw on 10.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WTNURLMoviesRequestFinishBlock)(NSArray * movies);
typedef void (^WTNURLRequestFailBlock)(NSError         * error);


@class WTNCity;


@interface WTNMoviesListRequest : NSObject

- (id)initWithCity:(WTNCity *)city
       finishBlock:(WTNURLMoviesRequestFinishBlock)finishBlock
         failBlock:(WTNURLRequestFailBlock)failBlock;

- (void)start;

@property (nonatomic, strong) WTNCity                        *city;
@property (nonatomic, strong) WTNURLMoviesRequestFinishBlock finishBlock;
@property (nonatomic, strong) WTNURLRequestFailBlock         failBlock;

@end
