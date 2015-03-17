//
//  TableUtils.h
//  GWCClub
//
//  Created by yulong chen on 13-1-30.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableUtils : NSObject
+(NSString*) delCreateData:(NSString*)strDate;

//+(UITableViewCell *) getNormalNewsCell:(UITableView*) tableView dataBean:(NewsBean*)bean indexPath:(NSIndexPath*)indexPath;

/**
 * 获取更多项单元格
 * @param tableView 表格
 * @return 生成的单元格
 **/
+(UITableViewCell*) getMoreCell:(UITableView *)tableView;

@end
