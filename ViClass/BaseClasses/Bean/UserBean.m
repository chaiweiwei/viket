//
//  UserBean.m
//  FunCat
//  用户Bean
//  Created by alidao on 14-9-29.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "UserBean.h"
#import "JSONUtils.h"

@implementation UserBean

-(void) setUid:(NSString *)uid{
    if (!uid) {
        _uid=nil;
    }
    if ([uid isKindOfClass:[NSString class]]) {
        _uid=uid;
    }else{
        _uid=[NSString stringWithFormat:@"%@",uid];
    }
}

-(void) setUserInfo:(id) userInfo{
    if (_userInfo) {
        _userInfo=nil;
    }
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        _userInfo=(UserInfoBean*)[JSONUtils jsonToBeanWithObject:userInfo toBeanClass:@"UserInfoBean"];
    }else{
        _userInfo=userInfo;
    }
}

-(void) setUserBehaviour:(id) userBehaviour{
    if (_userBehaviour) {
        _userBehaviour=nil;
    }
    if ([userBehaviour isKindOfClass:[NSDictionary class]]) {
        _userBehaviour=(UserBehaviourBean*)[JSONUtils jsonToBeanWithObject:userBehaviour toBeanClass:@"UserBehaviourBean"];
    }else{
        _userBehaviour=userBehaviour;
    }
}

-(NSString*) inviteRegister{
    if (!_inviteRegister || [_inviteRegister isEqualToString:@""]) {
        NSString *url=[kServerUrl stringByAppendingFormat:@"h5/user/register?id=%@",self.uid];
        if(self.userInfo && self.userInfo.nickname && ![self.userInfo.nickname isEqualToString:@""]){
            _inviteRegister=[NSString stringWithFormat:@"我是%@，%@,详情点击%@",self.userInfo.nickname,shareDescription,url];
        }else{
            _inviteRegister=[NSString stringWithFormat:@"%@,详情点击%@",shareDescription,url];
        }
    }
    return _inviteRegister;
}

/**
 * @param 获取状态值
 * @return status
 */
-(NSString*) getStringStatus{
    if (self.status) {
        NSInteger value=[self.status integerValue];
        if (value==1) {
            return @"使用中";
        }else if (value==2) {
            return @"已禁用";
        }
    }
    return @"未激活";
}

/**
 * @param 获取用户来源
 * @return source
 */
-(NSString*) getStringSource {
    if (self.source) {
        NSInteger value=[self.source integerValue];
        if (value==1) {
            return @"APP";
        }else if (value==2) {
            return @"微信";
        }else if (value==3) {
            return @"WAP";
        }else if (value==4) {
            return @"WEB";
        }
    }
    return @"系统分配";
}

-(NSString*) getInviteContent:(int)type{
    NSString *description=nil;
    if (type==2) {
        NSRange range=[self.inviteRegister rangeOfString:@"http://" options:NSBackwardsSearch];
        NSInteger location=range.location;
        if(range.location==NSNotFound){
            range=[self.inviteRegister rangeOfString:@"https://" options:NSBackwardsSearch];
            location=range.location;
        }
        if (location!=NSNotFound) {
            description=[self.inviteRegister substringToIndex:location];
        }else{
            
        }
        NSLog(@"description:%@",description);
        return description;
    }else{
        return self.inviteRegister;
    }
}

-(NSString*) getShareUrl{
    NSString *description=self.inviteRegister;
    NSRange range=[description rangeOfString:@"http://" options:NSBackwardsSearch];
    NSInteger location=range.location;
    if(range.location==NSNotFound){
        range=[description rangeOfString:@"https://" options:NSBackwardsSearch];
        location=range.location;
    }
    NSString *url=nil;
    if (location!=NSNotFound) {
        url=[description substringFromIndex:location];
        url=[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        url=[kServerUrl stringByAppendingFormat:@"h5/user/register?id=%@",self.uid];
    }
    NSLog(@"url:%@",url);
    return url;
}

- (void)dealloc
{
    self.uid=nil;
    self.sessionKey=nil;
    self.sid=nil;
    self.isNew=nil;
    self.username=nil;
    self.mobile=nil;
    self.email=nil;
    self.status=nil;
    self.source=nil;
    self.noteName=nil;
    self.userInfo=nil;
    self.userBehaviour=nil;
    self.haspayPassword=nil;
    self.inviteRegister=nil;
    self.extra=nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
