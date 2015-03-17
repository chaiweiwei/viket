//
//  AddressDao.h
//  hyt_ios
//  地址dao
//  Created by yulong chen on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDBaseDao.h"
#import "AddressBean.h"

@interface AddressDao : ALDBaseDao

/**
 * 新增地址,存在则更新
 * @param address 地址对象
 * @return 成功返回true,失败返回false
 */
-(BOOL) addAddress:(AddressBean *) address;

/**
 * 更新地址,不存在则新增
 * @param address 地址对象
 * @return 成功返回true,失败返回false
 */
-(BOOL) updateAddress:(AddressBean *) address;

/**
 * 删除地址
 * @param addrId 地址id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteAddress:(long) addrId;

/**
 *  根据地址id，查询地址详情
 *  @param addrId 地址id
 *  @return 返回地址AddressBean对象
 */
-(AddressBean *) queryAddresses:(long) addrId;

/**
 * 清理数据
 **/
-(BOOL) clearData;

@end
