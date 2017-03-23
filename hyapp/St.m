//
//  St.m
//  weblogin
//
//  Created by mac on 16/5/4.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import "St.h"

@implementation St
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];                     //r
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];                     //g
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];                     //b
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+(void)promptInformation:(NSString *)infoStr ShowViewContent:(UIView *)showView viewTime:(int)viewTime{
    if (infoStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:YES];
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(infoStr, nil);
        hud.minSize = CGSizeMake(infoStr.length * 20, 60.0f);//(132.f, 108.0f)
        [hud hide:YES afterDelay:viewTime];
    }
}

+(NSMutableDictionary *)getURLParameters:(NSString *)url{
    NSRange range = [url rangeOfString:@"?"];
    if (range.location== NSNotFound) {
        return nil;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *parametersString= [url substringFromIndex:range.location + 1];
    if ([parametersString containsString:@"&"]) {
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            if(key == nil || value == nil){
                continue;
            }
            id existValue = [params valueForKey:key];
            if(existValue != nil){
                if([existValue isKindOfClass:[NSArray class]]){
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    [params setValue:items forKey:key];
                }else{
                    [params setValue:@[existValue, value] forKey:key];
                }
            }else{
                [params setValue:value forKey:key];
            }
        }
    }else{
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        if(pairComponents.count == 1){
            return nil;
        }
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        if(key == nil || value == nil){
            return nil;
        }
        [params setValue:value forKey:key];
    }
    return params;
}

@end
