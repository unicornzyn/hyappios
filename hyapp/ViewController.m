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

@interface ViewController (){
    //UIView *view;
    UIWebView *iwebview;
    //NSTimer *timer;
    UIWebView *loadingview;
    NSString *website;
    NSString *websitescan;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
    view = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *img = [UIImage imageNamed:@"yidao_bg_02"];
    UIImageView *imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    [imgview setImage:img];
    [view addSubview:imgview];
    
    UIButton *buttonIndex =[UIButton buttonWithType:UIButtonTypeCustom];
    buttonIndex.frame= CGRectMake((self.view.frame.size.width-80)/2, self.view.frame.size.height-165, 80, 30);
    buttonIndex.backgroundColor=[St colorWithHexString:@"#AAAAAA"];
    buttonIndex.layer.cornerRadius=4;
    [buttonIndex setTitle:@"跳转首页" forState:UIControlStateNormal];
    [buttonIndex setTitleColor:[St colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [buttonIndex addTarget:self action:@selector(buttonIndexAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:buttonIndex];
    
    UIButton *buttonLogin =[UIButton buttonWithType:UIButtonTypeCustom];
    buttonLogin.frame= CGRectMake((self.view.frame.size.width-80)/2, self.view.frame.size.height-120, 80, 30);
    buttonLogin.backgroundColor=[St colorWithHexString:@"#AAAAAA"];
    buttonLogin.layer.cornerRadius=4;
    [buttonLogin setTitle:@"登录" forState:UIControlStateNormal];
    [buttonLogin setTitleColor:[St colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [buttonLogin addTarget:self action:@selector(buttonLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:buttonLogin];
    
    [self.view addSubview:view];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
    */
    website=@"http://yuyin.91huayi.net/";
    websitescan=@"http://mobile.kjpt.91huayi.com/";
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
    
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@m/index.html",website]];
    //NSURL *url = [[NSURL alloc]initWithString:@"http://z.puddingz.com/t.html"];
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
    [iwebview loadRequest:request];
    //[iwebview setHidden:YES];
    iwebview.delegate=self;
    [self.view addSubview:iwebview];
    
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [loadingview setHidden:NO];
    [webView setHidden:YES];
    

}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"apploading"]=self;

    [loadingview setHidden:YES];
    [webView setHidden:NO];
    NSString *url =webView.request.URL.absoluteString;
    if([url hasPrefix:[NSString stringWithFormat:@"%@AppScan.aspx",websitescan]]){
        //扫描二维码
        ScanQrcodeViewController *scan = [[ScanQrcodeViewController alloc]init];
        [self presentViewController:scan animated:YES completion:nil];
    }else if([url hasPrefix:[NSString stringWithFormat:@"%@GetAppId.aspx",websitescan]]){
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@GetAppIdReceive.aspx?para=%@",websitescan,[self getAppId]]];
        NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
        [webView loadRequest:request];

    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *nc =[NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(ncmethod:) name:@"go" object:nil];
}
-(void)ncmethod:(NSNotification*)sender{
    NSString *result=[sender.userInfo objectForKey:@"result"];
    if(![result isEqualToString:@""]){
        NSString *encodingresult= (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               
                                                                                               (__bridge CFStringRef)result,NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@AppScanReceive.aspx?para=%@",websitescan,encodingresult]];
        NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
        [iwebview loadRequest:request];
    }else{
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@AppScanning.aspx",websitescan]];
        NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:url];
        [iwebview loadRequest:request];
    }
}

-(NSString *)getAppId{
    NSString *strUUID=[[NSUserDefaults standardUserDefaults] stringForKey:@"hyuuid"];
    if(strUUID==nil||strUUID==NULL||[strUUID isEqualToString:@""]){
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        [[NSUserDefaults standardUserDefaults] setValue:strUUID forKey:@"hyuuid"];
    }
    return strUUID;
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

@end
