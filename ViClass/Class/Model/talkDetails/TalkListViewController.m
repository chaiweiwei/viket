//
//  TalkListViewController.m
//  WeTalk
//
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "TalkListViewController.h"

@interface TalkListViewController ()

@end

@implementation TalkListViewController

- (void)dealloc
{
    
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 180)];
    image.image = [UIImage imageNamed:@"bg_vshuo"];
    [self.view addSubview:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
