//
//  ViewController.m
//  HonLiHomeWork
//
//  Created by 周书阳 on 16/4/13.
//  Copyright © 2016年 zhoushuyang. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"
@interface ViewController ()<MKMapViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,UITextFieldDelegate>

@property (nonatomic,strong)CLLocationManager *locationManager;

@property (nonatomic,strong)MKMapView *mapView;
@property (nonatomic,strong)NSArray *placeArr;

@property (nonatomic,copy)NSString *firstText;
@property (nonatomic,copy)NSString *lastText;


@property (nonatomic,strong)UITextField *firstLocation;
@property (nonatomic,strong)UITextField *lastLocation;


@property (nonatomic,strong)CLPlacemark *placeMark1;
@property (nonatomic,strong)CLPlacemark *placeMark2;


@end

@implementation ViewController
/*
 
 
 ****************在调试的时候 记得把模拟器的 Debug->Custom Location 模拟经纬度 设置为自己想要的地方******************
 *************************郑州  经度：34.78  维度：113.65  ***********************
 
 
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatLocationManager];
    [self creatMap];
    [self creatButn];
    self.view.backgroundColor = [UIColor purpleColor];
}

- (void)creatLocationManager {
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>8.0f) {
        [_locationManager requestAlwaysAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

#pragma -mark 创建地图
- (void)creatMap {
    _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(10, 150, self.view.frame.size.width-20, self.view.frame.size.height-180)];
    [self.view addSubview:_mapView];
    _mapView.delegate = self;
    _mapView.layer.cornerRadius = 20;
    _mapView.clipsToBounds = YES;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;

}
#pragma -mark 创建视图UI控件
- (void)creatButn {
    UIButton *loginButn = [UIButton buttonWithType:UIButtonTypeSystem];
    loginButn.frame = CGRectMake(10, 20, 180, 35);
    loginButn.backgroundColor = [UIColor cyanColor];
    loginButn.layer.cornerRadius = 10;
    loginButn.clipsToBounds = YES;
    [loginButn setTitle:@"热点地区搜索" forState:UIControlStateNormal];
    loginButn.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButn.titleLabel.font = [UIFont systemFontOfSize:20];
    [loginButn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButn addTarget: self action:@selector(loginPress:) forControlEvents:UIControlEventTouchUpInside];
    loginButn.tag = 201;
    
    UIButton *butn = [UIButton buttonWithType:UIButtonTypeSystem];
    butn.frame = CGRectMake(220, 20, 180, 35);
    butn.backgroundColor = [UIColor cyanColor];
    butn.layer.cornerRadius = 10;
    butn.clipsToBounds = YES;
    [butn setTitle:@"返回我的位置" forState:UIControlStateNormal];
    butn.titleLabel.textAlignment = NSTextAlignmentCenter;
    butn.titleLabel.font = [UIFont systemFontOfSize:20];
    [butn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [butn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:butn];
    
    
    
//左侧提示
    UILabel *lable1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, 25)];
    lable1.text = @"起点位置";
    lable1.font =[UIFont systemFontOfSize:20];
    lable1.textColor = [UIColor blueColor];
    
    UILabel *lable2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, 25)];
    lable2.text = @"终点位置";
    lable2.font =[UIFont systemFontOfSize:20];
    lable2.textColor = [UIColor blueColor];
    
//起点输入框
    UITextField *firstLocation = [[UITextField alloc]initWithFrame:CGRectMake(10, 60, self.view.frame.size.width-20, 25)];
    firstLocation.delegate = self;
    self.firstLocation = firstLocation;
    firstLocation.backgroundColor = [UIColor cyanColor];
    firstLocation.clearButtonMode = UITextFieldViewModeUnlessEditing;
    firstLocation.layer.cornerRadius = 3;
    firstLocation.clipsToBounds = YES;
    firstLocation.font = [UIFont systemFontOfSize:18];
    firstLocation.adjustsFontSizeToFitWidth = YES;
    firstLocation.minimumFontSize = 12;
    firstLocation.placeholder = @"请输入起点位置";
    firstLocation.autocorrectionType = UITextAutocorrectionTypeDefault ;
    firstLocation.returnKeyType = UIReturnKeyNext;
    firstLocation.tag = 200;
    firstLocation.leftViewMode = UITextFieldViewModeAlways;
    firstLocation.leftView = lable1;
    
    
//终点输入框
    UITextField *firstLocation1 = [[UITextField alloc]initWithFrame:CGRectMake(10, 90,self.view.frame.size.width-20, 25)];
    firstLocation1.delegate = self;
    self.lastLocation = firstLocation1;
    firstLocation1.backgroundColor = [UIColor cyanColor];
    firstLocation1.clearButtonMode = UITextFieldViewModeUnlessEditing;
    firstLocation1.layer.cornerRadius = 3;
    firstLocation1.clipsToBounds = YES;
    firstLocation1.font = [UIFont systemFontOfSize:18];
    firstLocation1.adjustsFontSizeToFitWidth = YES;
    firstLocation1.minimumFontSize = 12;
    firstLocation1.placeholder = @"请输入终点位置";
    firstLocation1.autocorrectionType = UITextAutocorrectionTypeDefault ;
    firstLocation1.returnKeyType = UIReturnKeyDone;
    firstLocation1.tag = 201;
    firstLocation1.leftViewMode = UITextFieldViewModeAlways;
    firstLocation1.leftView = lable2;

//创建*****路线按钮
    UIButton *butn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    butn2.frame = CGRectMake(10, 120, 180, 25);
    butn2.backgroundColor = [UIColor cyanColor];
    butn2.layer.cornerRadius = 10;
    butn2.clipsToBounds = YES;
    [butn2 setTitle:@"查询路线和距离" forState:UIControlStateNormal];
    butn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    butn2.titleLabel.font = [UIFont systemFontOfSize:18];
    [butn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [butn2 addTarget:self action:@selector(road:) forControlEvents:UIControlEventTouchUpInside];
//清除******路线按钮
    UIButton *butn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    butn3.frame = CGRectMake(220, 120, 180, 25);
    butn3.backgroundColor = [UIColor cyanColor];
    butn3.layer.cornerRadius = 10;
    butn3.clipsToBounds = YES;
    [butn3 setTitle:@"清除路线" forState:UIControlStateNormal];
    butn3.titleLabel.textAlignment = NSTextAlignmentCenter;
    butn3.titleLabel.font = [UIFont systemFontOfSize:18];
    [butn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [butn3 addTarget:self action:@selector(delegateRoad:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:firstLocation];
    [self.view addSubview:firstLocation1];
    [self.view addSubview:butn2];
    [self.view addSubview:butn3];
    [self.view addSubview:loginButn];
}
//************************创建路线按钮对应事件
- (void)road:(UIButton *)butn {
    CLGeocoder *gecoorder = [[CLGeocoder alloc]init];
    NSLog(@"周书阳%@ %@ ",self.firstLocation.text,self.lastLocation.text);
    [gecoorder geocodeAddressString:self.firstLocation.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error) {
            NSLog(@"没有找到位置 %@",error);
            return ;
        }
        self.placeMark1 = [placemarks lastObject];
        //就是这个方法   placeMark1数组里面 会存有经纬度 我求终点坐标  只需要最后一个元素 就行了
        NSLog(@"%@",self.placeMark1);
           }];
    
    CLGeocoder *gecoorder1 = [[CLGeocoder alloc]init];
    [gecoorder1 geocodeAddressString:self.lastLocation.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error) {
            NSLog(@"没有找到位置 %@",error);
            return ;
        }
        self.placeMark2 = [placemarks lastObject];
//        NSLog(@"%@",self.placeMark2);
        [self performSelector:@selector(makeMap)];
    }];
    NSLog(@"*******%@ %@" ,self.placeMark1,self.placeMark2);
}
//创建导航地图按钮对应事件
- (void)makeMap{
    
            //起点的Item
            MKMapItem *startmapItem = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:self.placeMark1]];
            //终点的Item
            MKMapItem *finishmapItem = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:self.placeMark2]];
            //发起导航请求
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
            request.source = startmapItem;
            request.destination = finishmapItem;
    
            //发起导航
            MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
            //计算导航结果
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
                if (response.routes.count == 0|| error) {
                    NSLog(@"没有计算出路线%@",error);
                    return ;
                }
                //遍历所有的路线
                [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MKPolyline *line = obj.polyline;
                    //在地图上画出一条路线
                    [_mapView addOverlay:line];
                    CLLocationDistance distance = [self.placeMark1.location distanceFromLocation:self.placeMark2.location ]/1000;
                    NSString *distanceStr = [NSString stringWithFormat:@"%.2f千米",distance];
                    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"两地的最短距离" message:distanceStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alter show];
                    
                    //创建起点大头针
                    MyAnnotation *an1 = [[MyAnnotation alloc]init];
                    an1.coordinate = CLLocationCoordinate2DMake(self.placeMark1.location.coordinate.latitude, self.placeMark1.location.coordinate.longitude);
                    //地名
                    an1.title = self.placeMark1.name;
                    //街道
                    an1.subtitle = self.placeMark2.thoroughfare;
                    [_mapView addAnnotation:an1];
                    
                    
                    //创建终点大头针
                    MyAnnotation *an2 = [[MyAnnotation alloc]init];
                    an2.coordinate = CLLocationCoordinate2DMake(self.placeMark2.location.coordinate.latitude, self.placeMark2.location.coordinate.longitude);
                    an2.title = self.placeMark2.name;
                    an2.subtitle = self.placeMark2.thoroughfare;
                    [_mapView addAnnotation:an2];
                    
                }];
                
            }];
 
}
//清除路线的按钮相应事件
- (void)delegateRoad:(UIButton *)butn {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
}
//返回我的位置按钮相应事件
- (void)back:(UIButton *)sender {

    [_mapView setRegion:MKCoordinateRegionMake(_mapView.userLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    
}
//热点查询显示框
- (void)loginPress:(UIButton*)butn {

    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"附近热点地区" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"医院",@"酒店",@"学校",@"网吧",@"商场",nil];
        [ac showInView:self.view];

    
}
#pragma -mark UIActionSheetDelegate
//点击分栏
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",buttonIndex);
    [self search:[actionSheet buttonTitleAtIndex:buttonIndex]];
    //在这里面做事件的分发
}
//触发分栏对应事件
- (void)search:(NSString*)title {
    
    [_mapView removeAnnotations:_mapView.annotations];
    MKLocalSearchRequest * request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = title;
    request.region = MKCoordinateRegionMake(_mapView.userLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05));
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    //一个异步的请求
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",response.mapItems);
        
        //枚举遍历
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          
            MyAnnotation *ant = [[MyAnnotation alloc]init];
            //经纬度必须要设置
            ant.coordinate = obj.placemark.location.coordinate;
            ant.title = obj.name;
            ant.subtitle = obj.phoneNumber;
            //把大头针添加到地图上面
            [_mapView addAnnotation:ant];
        }];
    }];
    
}
#pragma -mark MKMapViewDelegate
//更新位置时候的代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation * newLocation = [locations lastObject];
    // 停止实时定位
    [self.locationManager stopUpdatingLocation];
    
    // 取得经纬度
    CLLocationCoordinate2D coord2D = newLocation.coordinate;
    double latitude = coord2D.latitude;
    double longitude = coord2D.longitude;
    NSLog(@"纬度 = %f 经度 = %f",latitude,longitude);
    
    // 取得精度
    CLLocationAccuracy horizontal = newLocation.horizontalAccuracy;
    CLLocationAccuracy vertical = newLocation.verticalAccuracy;
    NSLog(@"水平方 = %f 垂直方 = %f",horizontal,vertical);
    
    // 取得高度
    CLLocationDistance altitude = newLocation.altitude;
    NSLog(@"%f",altitude);
    
    // 取得此时时刻
    NSDate *timestamp = [newLocation timestamp];
    // 实例化一个NSDateFormatter对象
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    // 设定时间格式
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss a"];
    [dateFormat setAMSymbol:@"AM"]; // 显示中文, 改成"上午"
    [dateFormat setPMSymbol:@"PM"];
    // 求出当天的时间字符串，当更改时间格式时，时间字符串也能随之改变
    NSString *dateString = [dateFormat stringFromDate:timestamp];
    NSLog(@"此时此刻时间 = %@",dateString);
    
    
    // 反地理编码
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark * place in placemarks) {
            
            NSLog(@"name = %@",place.name); // 位置名
            NSLog(@"thoroughfare = %@",place.thoroughfare); // 街道
            NSLog(@"subAdministrativeArea = %@",place.subAdministrativeArea); // 子街道
            NSLog(@"locality = %@",place.locality); // 市
            NSLog(@"subLocality = %@",place.subLocality); // 区
            NSLog(@"country = %@",place.country); // 国家

        } 
    }]; 
} 

//触摸屏幕 使键盘消失
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self.view  endEditing:YES];
}
#pragma -mark TextFiledDelegate
//键盘按钮被点击
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    

    if (textField.tag == 200) {
        UITextField *textFiled1 =  (UITextField *)[self.view viewWithTag:201];
        [textFiled1 becomeFirstResponder];
    }
    
    if (textField.tag == 201) {
        [textField resignFirstResponder];
        NSLog(@"终点位置输入完成 %@ %@ %@ ",textField.text,self.firstLocation.text,self.lastLocation.text);
    }

 
    return YES;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *layRenderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    //线的颜色
    layRenderer.strokeColor = [UIColor purpleColor];
    //线的宽度
    layRenderer.lineWidth = 2;
    return layRenderer;
}

//拼接输入的字符串
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.firstLocation == textField) {
        _firstText = [self.firstLocation.text stringByAppendingString:string];
        
    }else {
        _lastText = [self.lastLocation.text stringByAppendingString:string];
        
    }
    return YES;

}
@end
