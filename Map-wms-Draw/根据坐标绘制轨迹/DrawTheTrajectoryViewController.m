//
//  DrawTheTrajectoryViewController.m
//  Map-wms-Draw
//
//  Created by 徐士友 on 2018/9/6.
//  Copyright © 2018年 xujiahui. All rights reserved.
//

#import "DrawTheTrajectoryViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "GetUrlSession.h"
#define huizhiTimes 0.03
#import "aesTools.h"
#define WeakSelf  __weak typeof(self) weakSelf = self
///居中点的个数
#define IntheMiddlePoint 2
///每次画线跳跃几个点
#define jumpPoints 3
@interface DrawTheTrajectoryViewController ()<MAMapViewDelegate>
{
    ///进行划线跳跃点个数数值
    NSInteger huizhiNum;
    
    MAPolyline *commonPolyline;
    BOOL endHuizhi;
    
    NSString * string2;
    
    UIButton *testButton1; // 一段一段线添加
    UIButton *testButton2; // 一段一段点添加

}

///轨迹线的样式  0:普通带颜色的线  1:自定义图片的线
@property(nonatomic,assign) NSInteger linesType;
////////划线
    ///显示要居中的点
@property(nonatomic,strong) NSMutableArray * TenPointArray ;
    ///划线的所有点
@property (nonatomic, strong) NSMutableArray * pointArray;


@property(nonatomic,strong)MAMapView *mapViewhome;

@end

@implementation DrawTheTrajectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //--------------没有密💊 ，b内部数据 不宜公开，请自行找数据 -------//////////////
    // 解析plist 获取Url
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"urldata" ofType:@"plist"]];
    //获取data 进行解密
    string2 = [aesTools AESToString:dataDict[@"URLDraw"]];
    //---------------------------------------------------------------------------------

    ///线的类型
    _linesType = 0;
    
    //   加载地图
    [self setMap];
    //绘制数据
    self.pointArray=[NSMutableArray array];
    [self huizhiData];
    [self.mapViewhome setMapType:MAMapTypeStandard];
    
    UIBarButtonItem *test1Bar = [[UIBarButtonItem alloc] initWithCustomView:[self commonButton:@"多段线" sel:@selector(test1Bar:)]];
    UIBarButtonItem *test2Bar = [[UIBarButtonItem alloc] initWithCustomView:[self commonButton:@"多段点" sel:@selector(test2Bar:)]];
    
    self.navigationItem.rightBarButtonItems = @[test1Bar, test2Bar];
}

- (UIButton *)commonButton:(NSString *)title sel:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)test1Bar:(UIButton *)sender{
    huizhiNum = 0;
    endHuizhi = NO;
    [self.mapViewhome removeOverlay: commonPolyline];
    commonPolyline = nil;
    [self jumpPoint];
}

- (void)test2Bar:(UIButton *)sender{
    huizhiNum = 0;
    endHuizhi = NO;
    [self.mapViewhome removeOverlay: commonPolyline];
    commonPolyline = nil;
    [self jumpPoint2];
}

#pragma mark Map
-(void)setMap{
    
    ///初始化地图
    self.mapViewhome = [[MAMapView alloc] initWithFrame:self.view.frame];
    self.mapViewhome.showsCompass= NO; // 设置成NO表示关闭指南针；YES表示显示指南针
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    self.mapViewhome.showsUserLocation = NO;
    [self.mapViewhome setZoomLevel:10 animated:YES];
    self.mapViewhome.userTrackingMode = MAUserTrackingModeFollow;
    self.mapViewhome.delegate =self;
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    self.mapViewhome.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    ///把地图添加至view
    
    self.mapViewhome.mapType = MAMapTypeNavi;
    [self.view addSubview:self.mapViewhome];
    
}
#pragma mark  ---------------------------------绘制轨迹-
-(void)huizhiData{
    
    huizhiNum = 0;
    _TenPointArray = [NSMutableArray array];
    
    NSString *polylineStr = @"116.472478,40.021957;116.472356,40.021956;116.472298,40.021932;116.472252,40.021894;116.472252,40.021658;116.471088,40.021657;116.470881,40.021657;116.470961,40.020667;116.470980,40.020590;116.470120,40.020590;116.467080,40.020650;116.466920,40.020500;116.466866,40.020409;116.466824,40.018977;116.466840,40.018340;116.466878,40.017366;116.466890,40.016920;116.466920,40.016540;116.466920,40.015930;116.465730,40.016000;116.465730,40.015920;116.463690,40.015440;116.463500,40.015390;116.463050,40.015230;116.461440,40.015250;116.460451,40.015321;116.459830,40.015380;116.459310,40.015450;116.458530,40.015590;116.457439,40.015853;116.456830,40.016040;116.456290,40.016190;116.456090,40.016260;116.454890,40.016590;116.454540,40.016800;116.454420,40.016910;116.454330,40.017020;116.454280,40.017170;116.454270,40.017380;116.454300,40.017480;116.454330,40.017530;116.454400,40.017620;116.454510,40.017710;116.454650,40.017770;116.454780,40.017800;116.455000,40.017810;116.455180,40.017780;116.455290,40.017740;116.455430,40.017660;116.455540,40.017560;116.455620,40.017440;116.455640,40.017380;116.455660,40.017230;116.455640,40.017040;116.455600,40.016910;116.455050,40.015630;116.454930,40.015180;116.454900,40.014980;116.454880,40.014430;116.454000,40.011730;116.453960,40.011550;116.453610,40.010560;116.452830,40.008170;116.451990,40.005680;116.451020,40.002710;116.450420,40.001000;116.449820,39.999650;116.449647,39.999334;116.449520,39.999080;116.449230,39.998570;116.448660,39.997610;116.447730,39.996200;116.446880,39.994870;116.446180,39.993850;116.445600,39.992940;116.444780,39.991710;116.443550,39.989810;116.443170,39.989280;116.442710,39.988590;116.440800,39.985630;116.438550,39.982160;116.436650,39.979360;116.435900,39.978220;116.435540,39.977700;116.435310,39.977320;116.434500,39.976100;116.433800,39.975010;116.432670,39.973300;116.432300,39.972750;116.432140,39.972480;116.431920,39.972220;116.431860,39.972130;116.431530,39.971520;116.431440,39.971290;116.431400,39.971170;116.431350,39.970930;116.431320,39.970640;116.431330,39.970370;116.431320,39.970180;116.431300,39.970040;116.431270,39.969970;116.431120,39.969860;116.430950,39.969800;116.430530,39.969780;116.428990,39.969770;116.428830,39.969750;116.428450,39.969730;116.426660,39.969540;116.426360,39.969490;116.426190,39.969450;116.425110,39.969410;116.424820,39.969410;116.415790,39.969170;116.411590,39.969090;116.407973,39.968964;116.406959,39.968952;116.404250,39.968870;116.400760,39.968800;116.398450,39.968730;116.397040,39.968690;116.394080,39.968600;116.393081,39.968606;116.392040,39.968540;116.389000,39.968450;116.387860,39.968440;116.386370,39.968392;116.384360,39.968300;116.383300,39.968290;116.381880,39.968260;116.381230,39.968260;116.379090,39.968220;116.376890,39.968180;116.374630,39.968100;116.373680,39.968080;116.370250,39.967970;116.369630,39.967960;116.365660,39.967840;116.363480,39.967800;116.359750,39.967780;116.355780,39.967780;116.355080,39.967790;116.353830,39.967760;116.352460,39.967760;116.349220,39.967760;116.347740,39.967730;116.344760,39.967710;116.343860,39.967690;116.340420,39.967660;116.340320,39.967650;116.334006,39.967589;116.330570,39.967510;116.327920,39.967390;116.323880,39.967220;116.322490,39.967150;116.321780,39.967090;116.320990,39.966940;116.320210,39.966730;116.319500,39.966490;116.316180,39.965280;116.313860,39.964400;116.313320,39.964220;116.312020,39.963750;116.311470,39.963560;116.310320,39.963190;116.309750,39.962980;116.309550,39.962880;116.309340,39.962740;116.308990,39.962470;116.308640,39.962110;116.308420,39.961780;116.308279,39.961445;116.308225,39.961241;116.308209,39.961080;116.308400,39.959860;116.308870,39.957770;116.309040,39.956890;116.309100,39.956360;116.309140,39.956040;116.309320,39.953950;116.309380,39.952920;116.309520,39.951300;116.309640,39.949580;116.309714,39.948734;116.309520,39.948390;116.309650,39.947070;116.309670,39.946370;116.309670,39.945842;116.309670,39.945520;116.309427,39.945521;116.308970,39.945510;116.308970,39.945430;116.309041,39.943937;116.308413,39.943936";
    
    NSArray *array1 = [polylineStr componentsSeparatedByString:@";"];
    
    for (int i=0; i<array1.count; i++) {
        NSArray *subArray = [array1[i] componentsSeparatedByString:@","];
        NSDictionary * di = @{@"latitude":[subArray lastObject],@"longitude":[subArray firstObject]};
        [self.pointArray addObject:di];
    }

//    [self jumpPoint2];
}

-(void)jumpPoint2{

    huizhiNum += jumpPoints;
    if (huizhiNum>(_pointArray.count-4)) {
        huizhiNum =_pointArray.count-1;
        endHuizhi = YES;
    }
    
    CLLocationCoordinate2D commonPolylineCoords[huizhiNum];
    for (int i=0; i<huizhiNum; i++) {
        NSDictionary * dic = self.pointArray[i];
        
        commonPolylineCoords[i].latitude=  [dic[@"latitude"] doubleValue];
        commonPolylineCoords[i].longitude=[dic[@"longitude"] doubleValue];
    }
   
    if (commonPolyline) {
        [commonPolyline setPolylineWithCoordinates:commonPolylineCoords count:huizhiNum];
    }
    else{
        //构造折线对象
        commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:huizhiNum];
        //在地图上添加折线对象
        [self.mapViewhome addOverlay: commonPolyline];
    }
    
    if (NO == endHuizhi) {
        [self performSelector:@selector(jumpPoint2) withObject:nil afterDelay:huizhiTimes];
    }
    
    
//    //设置地图中心位置
//    NSDictionary * huizhiDic2 = self.pointArray[huizhiNum];
//    MAPointAnnotation * a1= [[MAPointAnnotation alloc] init];
//    a1.coordinate = CLLocationCoordinate2DMake([huizhiDic2[@"latitude"] doubleValue], [ huizhiDic2[@"longitude"] doubleValue]);
//
//    //划线 显示进行中的后3个点
//    if (_TenPointArray.count<IntheMiddlePoint) {
//        [_TenPointArray addObject:a1];
//    }else{
//        [_TenPointArray replaceObjectAtIndex:0 withObject:a1];
//    }
//
//
//    //设置地图中心位置
//    if(endHuizhi){
//        //200, 100, 200, 100
//        [self.mapViewhome showOverlays:@[commonPolyline] edgePadding:UIEdgeInsetsMake(200, 100, 200, 100) animated:YES];
//        huizhiNum = 0;
//        return;
//    }else{
//
//        //        if (huizhiNum%9==0) {
//        //260, 150, 200, 100
//        [self.mapViewhome showAnnotations:_TenPointArray edgePadding:UIEdgeInsetsMake(260, 150, 200, 100) animated:YES];
//
//        //        }
//
//    }

}

-(void)jumpPoint{
    NSDictionary * huizhiDic2 = self.pointArray[0];
    MAPointAnnotation * a1= [[MAPointAnnotation alloc] init];
    a1.coordinate = CLLocationCoordinate2DMake([huizhiDic2[@"latitude"] doubleValue], [ huizhiDic2[@"longitude"] doubleValue]);
    
    [self.mapViewhome showAnnotations:@[a1] animated:YES];
    
    [self performSelector:@selector(mapViewHUIZHI) withObject:nil afterDelay:huizhiTimes];
    
}

- (void)mapViewHUIZHI{
    
    huizhiNum += jumpPoints;
    if (huizhiNum>(_pointArray.count-4)) {
        huizhiNum =_pointArray.count-1;
        endHuizhi = YES;
    }
    
    if (huizhiNum > self.pointArray.count) {
        return;
    }
    
    CLLocationCoordinate2D commonPolylineCoords[huizhiNum];
    for (int i=0; i<huizhiNum; i++) {
        NSDictionary * dic = self.pointArray[i];
        
        commonPolylineCoords[i].latitude=  [dic[@"latitude"] doubleValue];
        commonPolylineCoords[i].longitude=[dic[@"longitude"] doubleValue];
    }
  
    [self.mapViewhome removeOverlay:commonPolyline];
    //构造折线对象
    commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:huizhiNum];
    //在地图上添加折线对象
    [self.mapViewhome addOverlay: commonPolyline];
    
    //设置地图中心位置
    NSDictionary * huizhiDic2 = self.pointArray[huizhiNum];
    MAPointAnnotation * a1= [[MAPointAnnotation alloc] init];
    a1.coordinate = CLLocationCoordinate2DMake([huizhiDic2[@"latitude"] doubleValue], [ huizhiDic2[@"longitude"] doubleValue]);
    
    //划线 显示进行中的后3个点
    if (_TenPointArray.count<IntheMiddlePoint) {
        [_TenPointArray addObject:a1];
    }else{
        [_TenPointArray replaceObjectAtIndex:0 withObject:a1];
    }
    
    
    //设置地图中心位置
    if(endHuizhi){
        //200, 100, 200, 100
        [self.mapViewhome showOverlays:@[commonPolyline] edgePadding:UIEdgeInsetsMake(200, 100, 200, 100) animated:YES];
        huizhiNum = 0;
        return;
    }else{
        
//        if (huizhiNum%9==0) {
       //260, 150, 200, 100
            [self.mapViewhome showAnnotations:_TenPointArray edgePadding:UIEdgeInsetsMake(260, 150, 200, 100) animated:YES];
            
//        }
        
    }
    
    [self performSelector:@selector(mapViewHUIZHI) withObject:nil afterDelay:huizhiTimes];
    
}
#pragma mark - MAMapViewDelegate 样式
-(MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    
    
    //绘制线
    if ([overlay isKindOfClass:[MAPolyline class]])
        
    {

        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth= 8.f;
        polylineRenderer.strokeColor= [UIColor greenColor];
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType= kMALineCapRound;
        
        if (_linesType==0) {
            //普通颜色的线
            
        }else if (_linesType == 1){
            //线为图片的线
            polylineRenderer.strokeImage = [UIImage imageNamed:@"jiantouD"];
            
        }
        
        return polylineRenderer;
        
    }
    
    return nil;
}

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager
{
    
}


@end
