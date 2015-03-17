//
//  GrayPageControl.h
//  hyt_ios
//
//  Created by aaa a on 12-6-4.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrayPageControl : UIPageControl{
    UIImage* activeImage;
    UIImage* inactiveImage;
    
}
@property(nonatomic,retain)UIImage* activeImage;
@property(nonatomic,retain)UIImage* inactiveImage;
@end
