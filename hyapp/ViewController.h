//
//  ViewController.h
//  hyapp
//
//  Created by mac on 16/9/12.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
@protocol JavascriptExports <JSExport>
-(void)show;
-(void)hide;
@end

@interface ViewController : UIViewController<UIWebViewDelegate,JavascriptExports>


@end

