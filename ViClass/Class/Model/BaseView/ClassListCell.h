//
//  ClassListCell.h
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/20.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadHandler.h"

@interface ClassListCell : UITableViewCell
{
    DownloadHandler *down;
}
@property (nonatomic,retain)DownloadHandler *down;
@end
