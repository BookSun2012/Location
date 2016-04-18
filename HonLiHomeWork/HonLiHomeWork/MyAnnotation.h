//
//  MyAnnotation.h
//  HonLiHomeWork
//
//  Created by 周书阳 on 16/4/13.
//  Copyright © 2016年 zhoushuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MyAnnotation : NSObject<MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;
@end
