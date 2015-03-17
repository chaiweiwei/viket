//
//  MMLocationManager.h
//  MMLocationManager
//
//  Created by Chen Yaoqiang on 13-12-24.
//  Copyright (c) 2013年 Chen Yaoqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class ALDLocationManager;

@protocol ALDLocationManagerDelegate <NSObject>

@required
-(void) locationManager:(ALDLocationManager*) manager successedWithCLLocation:(CLLocation*) location;
-(void) locationManager:(ALDLocationManager*) manager failedWithError:(NSError*) error;

@optional
-(void) locationManager:(ALDLocationManager*) manager successedWithCity:(CLPlacemark *) plmark;

@end

@interface ALDLocationManager : NSObject

@property (nonatomic,retain) CLLocation *lastLocation;
@property (nonatomic,retain)NSString *lastCity;
@property (nonatomic,retain) CLPlacemark *lastPlmark;
@property (nonatomic,retain) NSString *lastAddress;

@property(nonatomic,weak) id<ALDLocationManagerDelegate> delegate;

+ (ALDLocationManager*) shareLocation;

-(void) startLocation;

-(void) startLocationWithDelegate:(id<ALDLocationManagerDelegate>) delegate;

-(void) stopLocation;

@end
