//
//  ViewController.m
//  hyapp
//
//  Created by mac on 16/9/12.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import "ViewController.h"
#import "ScanQrcodeViewController.h"
#import "St.h"
#import "WXApi.h"
#import "SAMKeychain.h"
#import "JPUSHService.h"
#import "LivenessViewController.h"
#import "LivingConfigModel.h"
#import "IDLFaceSDK/IDLFaceSDK.h"
#import "FaceParameterConfig.h"
#import "HYConfig.h"
#import "DetectionViewController.h"

@interface ViewController (){
    //UIView *view;
    UIWebView *iwebview;
    //NSTimer *timer;
    UIWebView *loadingview;
    NSString *website;
    NSString *websitescan;
    NSString *websitewxpay;
    NSString *pushtagurl;
    AppDelegate *_appDelegate;
    NSInteger showcc;
    NSString *returnurl;
    NSMutableData *responseData;
    NSString *appid;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    website=WEB_SITE;
    websitescan=WEB_SITE_SCAN;
    websitewxpay=WEB_SITE_WXPAY;
    
    pushtagurl=[NSString stringWithFormat:@"%@Account/tagTest/",website];
    
    //发送版本到服务器
    [self sendversion];
    
    self.view.backgroundColor=[UIColor whiteColor];
    //读取gif数据
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:filePath];
    float gif_w=self.view.frame.size.width*0.3;
    float gif_h=gif_w*109/329;
    loadingview = [[UIWebView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-gif_w)/2, (self.view.frame.size.height-gif_h)/2, gif_w, gif_h)];
    //取消回弹效果
    loadingview.scrollView.bounces=NO;
    loadingview.backgroundColor = [UIColor clearColor];
    //设置缩放模式
    loadingview.scalesPageToFit = YES;
    //用webView加载数据
    [loadingview loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.view addSubview:loadingview];
    
    iwebview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E230 Safari/601.1"}];
    appid=[self getAppId];
    
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Home/ios?appid=%@",website,appid]];
    if(self.topageparam.length>0){
        url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Home/ToProject?mykey=%@",website,self.topageparam]];
    }
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10];
    [iwebview loadRequest:request];
    //[iwebview setHidden:YES];
    iwebview.delegate=self;
    [self.view addSubview:iwebview];
    
    showcc=0;
    _appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //将要进入全屏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreenScreen:) name:UIWindowDidBecomeVisibleNotification object:nil];
    //将要退出全屏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreenScreen:) name:UIWindowDidBecomeHiddenNotification object:nil];
    //微信支付回调的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayoff:) name:@"Notification_wxpayoff" object:nil];
    
    //极光推送注册别名和标签
    [self setJPushTagsAndAlias:appid];
}
//将要进入全屏
-(void)willEnterFullscreenScreen:(NSNotification *)notification{
    if (showcc<2) {
        showcc++;
    }else{
        _appDelegate.isFull=YES;
    }
}
//将要退出全屏
-(void)willExitFullscreenScreen:(NSNotification *)notification{
    _appDelegate.isFull=NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"mylog %@",[error debugDescription]);
    /*
    if(error.code==-1009){
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"系统提示" message:@"数据加载失败,请检查网络状态" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    */
    if(error.code==-1009){
        NSString *homeurl = [NSString stringWithFormat:@"%@Home/ios?appid=%@",website,appid];
        NSDictionary *userinfo  = [error userInfo];
        NSString *errorHtml = [NSString stringWithFormat:@"<html><body><center style='padding:10px;'><h1>%@</h1><br /></br /></br><p><a href='%@'>返回首页</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href='%@'>重新加载</a></p></center></body></html>",[error localizedDescription],homeurl,[userinfo objectForKey:@"NSErrorFailingURLStringKey"]];
        
        [webView loadHTMLString:errorHtml baseURL:nil];
    }
    [loadingview setHidden:YES];
    [webView setHidden:NO];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [loadingview setHidden:NO];
    [webView setHidden:YES];
    _appDelegate.isFull=NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //context[@"apploading"]=self;
    [loadingview setHidden:YES];
    [webView setHidden:NO];
    NSString *url =webView.request.URL.absoluteString;
    NSLog(@"==>%@",url);
    
    if([url hasPrefix:[NSString stringWithFormat:@"%@AppScaningProj.aspx",websitescan]]){
        //扫描二维码
        ScanQrcodeViewController *scan = [[ScanQrcodeViewController alloc]init];
        scan.source = @"AppScanProj";
        [self presentViewController:scan animated:YES completion:nil];
        [webView goBack];
    }else if([url hasPrefix:[NSString stringWithFormat:@"%@AppScanning.aspx",websitescan]]){
        //二维码考勤
        ScanQrcodeViewController *scan = [[ScanQrcodeViewController alloc]init];
        scan.source = @"AppScanning";
        [self presentViewController:scan animated:YES completion:nil];
        [webView goBack];
    }else if([url hasPrefix:[NSString stringWithFormat:@"%@face.html",website]]){ //人脸识别
        NSMutableDictionary *dict = [St getURLParameters:url];
        if(dict != nil){
            //http://zshytest.91huayi.net/face.html?cardid=150430198611244135
            //http://zshytest.91huayi.net/face.html
            NSString *idnumber = [dict objectForKey:@"cardid"];
            NSLog(@"idnumber1=%@",idnumber);
            if(idnumber.length>0){
                if ([[FaceSDKManager sharedInstance] canWork]) {
                    NSString* licensePath = [[NSBundle mainBundle] pathForResource:FACE_LICENSE_NAME ofType:FACE_LICENSE_SUFFIX];
                    [[FaceSDKManager sharedInstance] setLicenseID:FACE_LICENSE_ID andLocalLicenceFile:licensePath];
                }
                //LivenessViewController* lvc = [[LivenessViewController alloc] init];
                //LivingConfigModel* model = [LivingConfigModel sharedInstance];
                //[lvc livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:1 idnumber:idnumber];
                
                DetectionViewController *lvc = [[DetectionViewController alloc] init];
                lvc.cardid = idnumber;
                UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lvc];
                navi.navigationBarHidden = true;
                [self presentViewController:navi animated:YES completion:nil];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"系统提示" message:@"未获取到身份证号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }
        [webView goBack];
    }else if([url hasPrefix:[NSString stringWithFormat:@"%@GetAppId.aspx",websitescan]]){
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@GetAppIdReceive.aspx?para=%@",websitescan,[self getAppId]]];
        NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }else if([url hasPrefix:[NSString stringWithFormat:@"%@wx_pay.aspx",websitewxpay]]){
        NSMutableDictionary *dict = [St getURLParameters:url];
        if(dict != nil){
            NSMutableString *stamp = [dict objectForKey:@"timestamp"];
            PayReq *req = [[PayReq alloc]init];
            req.partnerId = [dict objectForKey:@"partnerid"];
            req.prepayId = [dict objectForKey:@"prepayid"];
            req.nonceStr = [dict objectForKey:@"noncestr"];
            req.timeStamp = stamp.intValue;
            req.package = [dict objectForKey:@"package"];
            req.sign = [dict objectForKey:@"sign"];
            returnurl = [dict objectForKey:@"return_url"];
            NSString *error_backurl = [dict objectForKey:@"error_backurl"];
            if([WXApi isWXAppInstalled]){
                BOOL tt = [WXApi sendReq:req];
                NSLog(@"==>%d",tt);
            }else{
                NSLog(@"==>未安装微信");
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"系统提示" message:@"请先安装微信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                
                NSURL *url2 = [[NSURL alloc]initWithString:error_backurl];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url2];
                [iwebview loadRequest:request];

            }
            
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *nc =[NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(ncmethod:) name:@"go" object:nil];
}
-(void)ncmethod:(NSNotification*)sender{
    NSString *result=[sender.userInfo objectForKey:@"result"];
    NSString *source = [sender.userInfo objectForKey:@"source"];
    if(![result isEqualToString:@""]){
        NSString *encodingresult= (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               
                                                                                               (__bridge CFStringRef)result,NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        NSString *backurl = @"AppScanReceive.aspx";
        if([source isEqualToString:@"AppScanProj"]){
            backurl = @"AppScanProjValue.aspx";
        }else if([source isEqualToString:@"BaiduAI"] || [source isEqualToString:@"AppScanning"]){
            backurl = @"AppScanReceive.aspx";
        }
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@%@?para=%@",websitescan,backurl,encodingresult]];
        NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
        [iwebview loadRequest:request];
    }else{
        /*
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@AppScanning.aspx",websitescan]];
        NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
        [iwebview loadRequest:request];
         */
    }
}

-(NSString *)getAppId{
    /*
    NSString *strUUID=[[NSUserDefaults standardUserDefaults] stringForKey:@"hyuuid"];
    if(strUUID==nil||strUUID==NULL||[strUUID isEqualToString:@""]){
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        [[NSUserDefaults standardUserDefaults] setValue:strUUID forKey:@"hyuuid"];
    }
    return strUUID;
    */
    
    NSString * currentDeviceUUIDStr = [SAMKeychain passwordForService:@" "account:@"uuid"];
    if (currentDeviceUUIDStr == nil || [currentDeviceUUIDStr isEqualToString:@""])
    {
        NSUUID * currentDeviceUUID  = [UIDevice currentDevice].identifierForVendor;
        currentDeviceUUIDStr = currentDeviceUUID.UUIDString;
        currentDeviceUUIDStr = [currentDeviceUUIDStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        currentDeviceUUIDStr = [currentDeviceUUIDStr lowercaseString];
        [SAMKeychain setPassword: currentDeviceUUIDStr forService:@" "account:@"uuid"];
    }
    return currentDeviceUUIDStr;
}

-(void)show{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [loadingview setHidden:NO];
        [iwebview setHidden:YES];
    });
}
-(void)hide{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [loadingview setHidden:YES];
        [iwebview setHidden:NO];
    });
}

-(void)wxpayoff:(NSNotification *)notification{
    NSURL *url = [[NSURL alloc]initWithString:returnurl];
    
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
    
    [iwebview loadRequest:request];
}

/*
-(void)buttonIndexAction:(id)sender{
    [timer invalidate];
    timer=nil;
    [view setHidden:YES];
    [iwebview setHidden:NO];
}

-(void)buttonLoginAction:(id)sender{
    [timer invalidate];
    timer=nil;
    NSURL *url = [[NSURL alloc]initWithString:@"http://yuyin.91huayi.net/m/#/login"];
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
    [iwebview loadRequest:request];
    [view setHidden:YES];
    [iwebview setHidden:NO];
}

-(void)timerAction:(id)sender{
    [view setHidden:YES];
    [iwebview setHidden:NO];
}

*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendversion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];//app版本号 Version
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];//app的build号
    //NSLog(@"版本号:%@\nbuild号:%@\n",version,build);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@Home/ios_version?version=%@&flag=1",website,build]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)setJPushTagsAndAlias:(NSString *)appid{
    [JPUSHService setAlias:appid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        NSLog(@"jpush setAlias iResCode:%zd",iResCode);
    } seq:1];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",pushtagurl,appid]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(responseData == nil){
        responseData = [[NSMutableData alloc]init];
    }
    [responseData appendData:data];
}
// 当服务器返回所有数据时触发, 数据返回完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if([connection.currentRequest.URL.absoluteString hasPrefix:pushtagurl]){
        if(responseData!= nil){
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            if([dict isKindOfClass:[NSDictionary class]]){
                NSString *str = [dict objectForKey:@"data"];
                if(str.length>0){
                    NSArray *arr = [str componentsSeparatedByString:@","];
                    NSSet *set = [NSSet setWithArray:arr];
                    [JPUSHService setTags:set completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                        NSLog(@"jpush setTags iResCode:%zd",iResCode);
                    } seq:2];
                }else{
                    [JPUSHService cleanTags:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
                         NSLog(@"jpush setTags iResCode:%zd",iResCode);
                    } seq:3];
                }
            }
        }
    }
}
@end
