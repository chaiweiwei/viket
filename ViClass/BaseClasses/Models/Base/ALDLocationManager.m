//
//  MMLocationManager.m
//  MMLocationManager
//
//  Created by Chen Yaoqiang on 13-12-24.
//  Copyright (c) 2013年 Chen Yaoqiang. All rights reserved.
//

#import "ALDLocationManager.h"

@interface ALDLocationManager ()<CLLocationManagerDelegate>

@property(nonatomic,retain) CLLocationManager *locManager;
//@property(nonatomic) 
@property (nonatomic) NSTimeInterval lastLocationTimes;
@property (nonatomic) NSTimeInterval lastCityTimes;
@end

@implementation ALDLocationManager
#define kCacheEffectTimes 1800 //缓存有效时间，30分钟

+ (ALDLocationManager*) shareLocation;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)startLocation
{
    if (!_locManager) {
        self.locManager = [[CLLocationManager alloc] init];
        [_locManager setDelegate:self];
        [_locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }else{
        [_locManager stopUpdatingLocation];
    }
    if(isIOS8 && [self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locManager performSelector:@selector(requestAlwaysAuthorization) withObject:nil];
    }
    [_locManager startUpdatingLocation]; //开始获取经纬度
}

-(void) startLocationWithDelegate:(id<ALDLocationManagerDelegate>)delegate{
    self.delegate=delegate;
    [self startLocation];
}

-(void)stopLocation
{
    if (_locManager) {
        [_locManager stopUpdatingLocation];
    }
}

-(void) locationConvertToCity:(CLLocation*) newLocation{
    if (_delegate && [_delegate respondsToSelector:@selector(locationManager:successedWithCity:)]) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
         {
             if (placemarks.count >0   )
             {
                 CLPlacemark * plmark = [placemarks objectAtIndex:0];
                 
                 NSString * country = plmark.country;
                 NSString * city    = plmark.locality;
                 
                 self.lastCity=city;
                 self.lastCityTimes=[[NSDate date] timeIntervalSince1970];
                 NSLog(@"%@-%@-%@",country,city,plmark.name);
                 [_delegate locationManager:self successedWithCity:plmark];
             }else{
//                 NSString *city=[self getLastEffectCity];
                 CLPlacemark *plmark=[self getLastPlmark];
                 if (plmark!=nil) {
                     [_delegate locationManager:self successedWithCity:_lastPlmark];
                 }else{
                     if (!error) {
                         error=[NSError errorWithDomain:@"CLGeocoder error" code:100 userInfo:nil];
                     }
                     if ([_delegate respondsToSelector:@selector(locationManager:failedWithError:)]) {
                         [_delegate locationManager:self failedWithError:error];
                     }
                 }
             }
         }];
    }
}

#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    CLLocation *location=[self getLastEffectLocation];
    if (location) {
        if (_delegate && [_delegate respondsToSelector:@selector(locationManager:successedWithCLLocation:)]) {
            [_delegate locationManager:self successedWithCLLocation:location];
        }
        /////////获取位置城市信息
        [self locationConvertToCity:location];
    }else{
        if (!error) {
            error=[NSError errorWithDomain:@"locationManager didFailWithError" code:102 userInfo:nil];
        }
        if ([_delegate respondsToSelector:@selector(locationManager:failedWithError:)]) {
            [_delegate locationManager:self failedWithError:error];
        }
    }
    [self stopLocation];
}

-(void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    CLLocation *location=[self getLastEffectLocation];
    if (location) {
        if (_delegate && [_delegate respondsToSelector:@selector(locationManager:successedWithCLLocation:)]) {
            [_delegate locationManager:self successedWithCLLocation:location];
        }
        /////////获取位置城市信息
        [self locationConvertToCity:location];
    }else{
        if (!error) {
            error=[NSError errorWithDomain:@"locationManager monitoringDidFailForRegion" code:101 userInfo:nil];
        }
        if ([_delegate respondsToSelector:@selector(locationManager:failedWithError:)]) {
            [_delegate locationManager:self failedWithError:error];
        }
    }
    [self stopLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    self.lastLocation=[newLocation copy];
    self.lastLocationTimes=[[NSDate date] timeIntervalSince1970];
    if (_delegate && [_delegate respondsToSelector:@selector(locationManager:successedWithCLLocation:)]) {
        [_delegate locationManager:self successedWithCLLocation:newLocation];
    }
    /////////获取位置城市信息
    [self locationConvertToCity:newLocation];
    [self stopLocation];
}
#pragma mark end

-(CLLocation*) getLastEffectLocation{
    if (_lastLocation) {
        NSTimeInterval times=[[NSDate date] timeIntervalSince1970];
        if (times-_lastLocationTimes<kCacheEffectTimes) {
            return _lastLocation;
        }
    }
    return nil;
}

-(NSString*) getLastEffectCity{
    if (_lastCity) {
        NSTimeInterval times=[[NSDate date] timeIntervalSince1970];
        if (times-_lastCityTimes<kCacheEffectTimes) {
            return _lastCity;
        }
    }

    return nil;
}

-(CLPlacemark *)getLastPlmark
{
    if (_lastPlmark) {
        NSTimeInterval times=[[NSDate date] timeIntervalSince1970];
        if (times-_lastCityTimes<kCacheEffectTimes) {
            return _lastPlmark;
        }
    }
    return nil;
}

- (void)dealloc
{
    if (_locManager) {
        [_locManager stopUpdatingLocation];
        self.locManager=nil;
    }
}

@end
