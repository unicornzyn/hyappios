//
//  St.h
//  weblogin
//
//  Created by mac on 16/5/4.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
typedef void (^AjaxSuccessBlock)(NSDictionary *data);           //ajax成功的代码块
typedef void (^AjaxSuccessBlockData)(NSData *data);           //ajax成功的代码块
typedef void (^AjaxErrorBlock)(NSError *data);                  //ajax失败的代码块

@interface St : NSObject
+ (UIColor *) colorWithHexString: (NSString *)color;

+(void)promptInformation:(NSString *)infoStr ShowViewContent:(UIView *)showView viewTime:(int)viewTime;

+(NSMutableDictionary *)getURLParameters:(NSString *)url;
@end
