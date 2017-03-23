//
//  AppDelegate.h
//  hyapp
//
//  Created by mac on 16/9/12.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isFull;

@end

