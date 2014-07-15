//
//  WTNMainViewController.h
//  Watch2Night
//
//  Created by qw on 18.05.14.
//  Copyright (c) 2014 W2NCopr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTNMainViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton       *mapButton;
@property (nonatomic, weak) IBOutlet UIScrollView   *mainScrollView;

- (IBAction)mapButtonPressed:(id)sender;

- (void)hideMapViewController:(UIViewController *)vc;


@end
