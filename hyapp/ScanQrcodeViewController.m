//
//  ScanQrcodeViewController.m
//  weblogin
//
//  Created by mac on 16/6/23.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import "ScanQrcodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
@interface ScanQrcodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;
@end

@implementation ScanQrcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _lbl.frame=CGRectMake(100, _lbl.frame.origin.y, _lbl.frame.size.width, _lbl.frame.size.height);
     _lastResult = YES;
    _btntest.frame=CGRectMake((SCREEN_WIDTH-_btntest.frame.size.width)/2, 390, _btntest.frame.size.width, _btntest.frame.size.height);
    
    [self startReading];
    
    [_btntest addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
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
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];
    
    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 创建输出对象
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    // 9.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake((124)/SCREEN_HEIGHT,((SCREEN_WIDTH-220)/2)/SCREEN_WIDTH,220/SCREEN_HEIGHT,220/SCREEN_WIDTH);
    
    // 10.设置扫描框
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2,124,220,220)];
    [self.view addSubview:boxView];
    
    
    boxView.layer.borderColor = [UIColor greenColor].CGColor;
    boxView.layer.borderWidth = 3;
    
    [self.view addSubview:boxView];
    
    // 设置扫描线
    /*
    CALayer *scanLayer = [[CALayer alloc] init];
    
    
    scanLayer.frame = CGRectMake(0, 0, boxView.bounds.size.width, 2);
    scanLayer.backgroundColor = [UIColor redColor].CGColor;
    [boxView.layer addSublayer:scanLayer];
    */
    // 开始会话
    [_captureSession startRunning];
    
    return YES;
}
- (void)stopReading
{
    // 停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
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
        [[NSNotificationCenter defaultCenter]postNotificationName:@"go" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:result,@"result", nil]];
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
