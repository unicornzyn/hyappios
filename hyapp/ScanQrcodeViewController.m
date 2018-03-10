//
//  ScanQrcodeViewController.m
//  weblogin
//
//  Created by mac on 16/6/23.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import "ScanQrcodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DetectionViewController.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_BOUNDS  [UIScreen mainScreen].bounds
#define TOP (SCREEN_HEIGHT-220)/2
#define LEFT (SCREEN_WIDTH-220)/2

#define kScanRect CGRectMake(LEFT, TOP, 220, 220)

@interface ScanQrcodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UILabel *lbl2;
    NSTimer * timer2; //倒计时
    CAShapeLayer *cropLayer;
}

@property (nonatomic) BOOL lastResult;
@property (nonatomic, strong) UIImageView * line;

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end

@implementation ScanQrcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //_lbl.frame=CGRectMake((SCREEN_WIDTH-_lbl.frame.size.width)/2, _lbl.frame.origin.y, _lbl.frame.size.width, _lbl.frame.size.height);
    
    //_btntest.frame=CGRectMake((SCREEN_WIDTH-_btntest.frame.size.width)/2, TOP + 220 + 20, _btntest.frame.size.width, _btntest.frame.size.height);
     //[_btntest addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    
    _lastResult = YES;
    
    [self configView];
    
   
    
    [self setCropRect:kScanRect];
    
    UILabel *lbl0 = [[UILabel alloc]initWithFrame:CGRectMake(0, TOP-100, SCREEN_WIDTH, 20)];
    [lbl0 setText:@"请扫描\"考勤二维码\""];
    lbl0.textAlignment = NSTextAlignmentCenter;
    [lbl0 setTextColor:OutSideColor];
    [self.view addSubview:lbl0];
    
    if([self.source isEqualToString:@"BaiduAI"]){
        lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(0, TOP-50, SCREEN_WIDTH, 20)];
        [lbl2 setText:[NSString stringWithFormat:@"扫码倒计时:%qi秒",self.totalseconds]];
        lbl2.textAlignment = NSTextAlignmentCenter;
        [lbl2 setTextColor:OutSideColor];
        [self.view addSubview:lbl2];
        timer2 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animationCountDown) userInfo:nil repeats:YES];
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-50)/2, TOP + 220 + 20, 50, 20)];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTintColor:OutSideColor];
    [btn addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

-(void)animationCountDown{
    if(--self.totalseconds>0){
        [lbl2 setText:[NSString stringWithFormat:@"扫码倒计时:%qi秒",self.totalseconds]];
    }else{
        __weak typeof(self) weakSelf = self;
        UIViewController* fatherViewController = weakSelf.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            DetectionViewController *lvc = [[DetectionViewController alloc]init];
            lvc.cardid = self.cardid;
            [fatherViewController presentViewController:lvc animated:YES completion:nil];
        }];
    }
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

-(void)configView{
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    //[self setCropRect:kScanRect];
    
    [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.3];
    
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}


- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:BackgroundColor.CGColor];
    [cropLayer setOpacity:0.9];
    
    
    [cropLayer setNeedsDisplay];
    
    
    [self.view.layer addSublayer:cropLayer];
    
}

- (void)setupCamera
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"go" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"result", nil]];
            }];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"无摄像头访问权限" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"go" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"result", nil]];
            }];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/SCREEN_HEIGHT;
    CGFloat left = LEFT/SCREEN_WIDTH;
    CGFloat width = 220/SCREEN_WIDTH;
    CGFloat height = 220/SCREEN_HEIGHT;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}


-(void)test:(id)sender{
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"go" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"result", nil]];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)startReading
{
    
    
    
    // 设置扫描线
    /*
    CALayer *scanLayer = [[CALayer alloc] init];
    
    
    scanLayer.frame = CGRectMake(0, 0, boxView.bounds.size.width, 2);
    scanLayer.backgroundColor = [UIColor redColor].CGColor;
    [boxView.layer addSublayer:scanLayer];
    */
    // 开始会话
    [_session startRunning];
    
    return YES;
}
- (void)stopReading
{
    // 停止会话
    [_session stopRunning];
    _session = nil;
}
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
        } else {
            NSLog(@"不是二维码");
        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}
- (void)reportScanResult:(NSString *)result
{
    [self stopReading];
    if (!_lastResult) {
        return;
    }
    _lastResult = NO;
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"go" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:result,@"result",self.source,@"source", nil]];
    }];
    // 以下处理了结果，继续下次扫描
    _lastResult = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
