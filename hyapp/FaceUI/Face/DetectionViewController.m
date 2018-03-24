//
//  DetectionViewController.m
//  IDLFaceSDKDemoOC
//
//  Created by 阿凡树 on 2017/5/23.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "DetectionViewController.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import <AVFoundation/AVFoundation.h>
#import "NetAccessModel.h"
#import "ScanQrcodeViewController.h"

@interface DetectionViewController ()
{
    NSTimer * timer; //倒计时
}

@property (nonatomic, readwrite, retain) UIView *animaView;
@end

@implementation DetectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 纯粹为了在照片成功之后，做闪屏幕动画之用
    self.animaView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.animaView.backgroundColor = [UIColor whiteColor];
    self.animaView.alpha = 0;
    [self.view addSubview:self.animaView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animationCountDown) userInfo:nil repeats:YES];
}

-(void)animationCountDown{
    if(--self.timeout>0){
        [self.timeoutLabel setText:[NSString stringWithFormat:@"倒计时:%ld秒",(long)self.timeout]];
    }else{
        __weak typeof(self) weakSelf = self;
        /*
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"认证超时" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //NSLog(@"知道啦");
                    }];
        [alert addAction:action];
         */
        UIViewController* fatherViewController = weakSelf.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            //[fatherViewController presentViewController:alert animated:YES completion:nil];
            [self timerStop];
            ScanQrcodeViewController *scan = [[ScanQrcodeViewController alloc]init];
            scan.source = @"AppScanning";
            [fatherViewController presentViewController:scan animated:YES completion:nil];

        }];
    }
}

-(void)timerStop{
    [timer invalidate];
    timer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IDLFaceDetectionManager sharedInstance] startInitial];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IDLFaceDetectionManager.sharedInstance reset];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    [IDLFaceDetectionManager.sharedInstance reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[IDLFaceDetectionManager sharedInstance] detectStratrgyWithImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(NSDictionary *images, DetectRemindCode remindCode) {
        switch (remindCode) {
            case DetectRemindCodeOK: {
                weakSelf.hasFinished = YES;
                [self warningStatus:CommonStatus warning:@"非常好"];
                if (images[@"bestImage"] != nil && [images[@"bestImage"] count] != 0) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:[images[@"bestImage"] lastObject] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* bestImage = [UIImage imageWithData:data];
                    NSLog(@"bestImage = %@",bestImage);
                }
                
                void (^showMsg)(NSString *)=^(NSString *msg){
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        //NSLog(@"知道啦");
                    }];
                    [alert addAction:action];
                    UIViewController* fatherViewController = weakSelf.presentingViewController;
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        [fatherViewController presentViewController:alert animated:YES completion:nil];
                    }];
                };
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[weakSelf closeAction];
                    if (images[@"bestImage"] != nil && [images[@"bestImage"] count] != 0) {
                        [self warningStatus:CommonStatus warning:@"正在验证身份，请稍侯..."]; //bestImageStr
                        [self timerStop];
                        NSData* data = [[NSData alloc] initWithBase64EncodedString:[images[@"bestImage"] lastObject] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        UIImage* bestImage = [UIImage imageWithData:data];
                        NSLog(@"bestImage = %@",bestImage);
                        NSString* bestImageStr = [[images[@"bestImage"] lastObject] copy];
                        NSLog(@"idnumber5=%@",self.cardid);
                        [[NetAccessModel sharedInstance] verifyFaceAndIDCard:weakSelf.cardid imageStr:bestImageStr completion:^(NSError *error, id resultObject) {
                            if (error == nil) {
                                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:resultObject options:NSJSONReadingAllowFragments error:nil];
                                if ([dict[@"errorCode"] integerValue] == 0) { //上传成功
                                    [self checkValid];
                                }else if([dict[@"errorCode"] integerValue] == 1){
                                    showMsg([dict[@"errMsg"] stringValue]);
                                }else if([dict[@"errorCode"] integerValue] == 3){
                                    showMsg(@"您还未进行人脸认证，请进行认证。");
                                }else{
                                    showMsg(@"未知错误");
                                }
                                
                            }else{
                                showMsg([error localizedDescription]);
                            }
                        }];
                    }
                    
                });
                [self singleActionSuccess:true];
                break;
            }
            case DetectRemindCodePitchOutofDownRange:
                [self warningStatus:PoseStatus warning:@"建议略微抬头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodePitchOutofUpRange:
                [self warningStatus:PoseStatus warning:@"建议略微低头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeYawOutofLeftRange:
                [self warningStatus:PoseStatus warning:@"建议略微向右转头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeYawOutofRightRange:
                [self warningStatus:PoseStatus warning:@"建议略微向左转头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodePoorIllumination:
                [self warningStatus:CommonStatus warning:@"光线再亮些"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeNoFaceDetected:
                [self warningStatus:CommonStatus warning:@"把脸移入框内"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeImageBlured:
                [self warningStatus:CommonStatus warning:@"请保持不动"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionLeftEye:
                [self warningStatus:occlusionStatus warning:@"左眼有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionRightEye:
                [self warningStatus:occlusionStatus warning:@"右眼有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionNose:
                [self warningStatus:occlusionStatus warning:@"鼻子有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionMouth:
                [self warningStatus:occlusionStatus warning:@"嘴巴有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionLeftContour:
                [self warningStatus:occlusionStatus warning:@"左脸颊有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionRightContour:
                [self warningStatus:occlusionStatus warning:@"右脸颊有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionChinCoutour:
                [self warningStatus:occlusionStatus warning:@"下颚有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeTooClose:
                [self warningStatus:CommonStatus warning:@"手机拿远一点"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeTooFar:
                [self warningStatus:CommonStatus warning:@"手机拿近一点"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeBeyondPreviewFrame:
                [self warningStatus:CommonStatus warning:@"把脸移入框内"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeVerifyInitError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyDecryptError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyInfoFormatError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyExpired:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyMissRequiredInfo:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyInfoCheckError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyLocalFileError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyRemoteDataError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeTimeout: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"超时" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"知道啦");
                    }];
                    [alert addAction:action];
                    UIViewController* fatherViewController = weakSelf.presentingViewController;
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        [fatherViewController presentViewController:alert animated:YES completion:nil];
                    }];
                });
                break;
            }
            case DetectRemindCodeConditionMeet: {
                self.circleView.conditionStatusFit = true;
            }
                break;
            default:
                break;
        }
        if (remindCode == DetectRemindCodeConditionMeet || remindCode == DetectRemindCodeOK) {
            self.circleView.conditionStatusFit = true;
        }else {
            self.circleView.conditionStatusFit = false;
        }
    }];
}

- (void)checkValid
{
    __weak typeof(self) weakSelf = self;
    
    void (^showMsg)(NSString *,BOOL)=^(NSString *msg,BOOL isrestartbaiduai){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if(isrestartbaiduai){
                UIViewController* fatherViewController = weakSelf.presentingViewController;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    DetectionViewController *lvc = [[DetectionViewController alloc]init];
                    lvc.cardid = self.cardid;
                    lvc.timeout = self.timeout;
                    [fatherViewController presentViewController:lvc animated:YES completion:nil];
                }];
            }
        }];
        [alert addAction:action];
        UIViewController* fatherViewController = weakSelf.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [fatherViewController presentViewController:alert animated:YES completion:nil];
        }];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NetAccessModel sharedInstance] queryPhotoValid:weakSelf.cardid completion:^(NSError *error2, id resultObject2) {
            if (error2 == nil){
                NSDictionary* dict2 = [NSJSONSerialization JSONObjectWithData:resultObject2 options:NSJSONReadingAllowFragments error:nil];
                if ([dict2[@"errorCode"] integerValue] == 1){ //错误
                    showMsg([dict2[@"errMsg"] stringValue],false);
                }else if([dict2[@"errorCode"] integerValue] == 2){ //正在排队
                    NSString *aaa = [NSString stringWithFormat:@"前方排队人数%@，请耐心等待...",[dict2[@"errMsg"] stringValue]];
                    [self warningStatus:CommonStatus warning:aaa];
                    [self checkValid];
                }else if([dict2[@"errorCode"] integerValue] == 3){ //正在排队
                    [self warningStatus:CommonStatus warning:@"正在处理，请稍侯..."];
                    [self checkValid];
                }else if([dict2[@"errorCode"] integerValue] == 4){ //验证通过
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"go" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"facesuccess",@"result",self.parakey,@"parakey", nil]];
                    }];
                }else if([dict2[@"errorCode"] integerValue] == 5){ //验证未通过
                    
                    showMsg([dict2[@"errMsg"] stringValue],true);
                }else if([dict2[@"errorCode"] integerValue] == 6){ //还未处理完 继续请求
                    [self checkValid];
                }else if([dict2[@"errorCode"] integerValue] == 7){ //人脸识别失败
                    showMsg(@"人脸识别失败",false);
                }else{
                    
                    showMsg(@"未知错误",false);
                }
            }else{
                //self.isLoop = false;
                showMsg([error2 localizedDescription],false);
                
            }
        }];
    });
}

- (void)dealloc
{
    
}
@end
