//
//  NetAccessModel.m
//  FaceSharp
//
//  Created by 阿凡树 on 2017/5/25.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "NetAccessModel.h"
#import "NSString+Additions.h"
#import "HYConfig.h"


@interface NetAccessModel ()

@end
@implementation NetAccessModel

+ (instancetype)sharedInstance {
    static NetAccessModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetAccessModel alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return self;
}
    
- (void)verifyFaceAndIDCard:(NSString *)idnumber imageStr:(NSString *)imageStr completion:(FinishBlockWithObject)completionBlock {
    NSDictionary* parm = @{@"token":@"",
                           @"cert_id":idnumber,
                           @"photo":imageStr
                           };
    NSLog(@"%@",[NSString stringWithFormat:@"%@FaceRecognition/api/UploadPhotoClient",WEB_SITE_AI]);
    NSLog(@"idnumber2=%@",idnumber);
    [[NetManager sharedInstance] postDataWithPath:[NSString stringWithFormat:@"%@FaceRecognition/api/UploadPhotoClient",WEB_SITE_AI] parameters:parm completion:^(NSError *error, id resultObject) {
        completionBlock(error,resultObject);
    }];
    
}

- (void)queryPhotoValid:(NSString *)idnumber completion:(FinishBlockWithObject)completionBlock {
    NSDictionary* parm = @{@"token":@"",
                           @"appid":@"1CC50D14-3CB1-4C2C-BF27-86959D705071",
                           @"cert_id":idnumber,
                           @"photo_from_type":@"2"
                           };
    NSLog(@"%@",[NSString stringWithFormat:@"%@FaceRecognition/api/QueryPhotoValidateAjax",WEB_SITE_AI]);
    NSLog(@"idnumber3=%@",idnumber);
    [[NetManager sharedInstance] getDataWithPath:[NSString stringWithFormat:@"%@FaceRecognition/api/QueryPhotoValidateAjax",WEB_SITE_AI] parameters:parm completion:^(NSError *error, id resultObject) {
        completionBlock(error,resultObject);
    }];
}

- (void)getScanQRCodeTimeOut:(FinishBlockWithObject)completionBlock {
    [[NetManager sharedInstance] getDataWithPath:[NSString stringWithFormat:@"%@handler/GetFaceOutTime.ashx",WEB_SITE_SCAN] parameters:nil completion:^(NSError *error, id resultObject) {
        completionBlock(error,resultObject);
    }];
}
@end
