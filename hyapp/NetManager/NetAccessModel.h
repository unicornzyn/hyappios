//
//  NetAccessModel.h
//  FaceSharp
//
//  Created by 阿凡树 on 2017/5/25.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetManager.h"

@interface NetAccessModel : NSObject

+ (instancetype)sharedInstance;

- (void)verifyFaceAndIDCard:(NSString *)idnumber imageStr:(NSString *)imageStr completion:(FinishBlockWithObject)completionBlock;

- (void)queryPhotoValid:(NSString *)idnumber completion:(FinishBlockWithObject)completionBlock;

//二维码扫描倒计时
- (void)getScanQRCodeTimeOut:(FinishBlockWithObject)completionBlock;
@end
