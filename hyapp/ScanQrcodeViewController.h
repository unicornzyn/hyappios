//
//  ScanQrcodeViewController.h
//  weblogin
//
//  Created by mac on 16/6/23.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OutSideColor [UIColor colorWithRed:246/255.0 green:166/255.0 blue:35/255.0 alpha:1]
#define BackgroundColor [UIColor colorWithRed:47/255.0 green:47/255.0 blue:51/255.0 alpha:1]

@interface ScanQrcodeViewController : UIViewController
//@property (weak, nonatomic) IBOutlet UILabel *lbl;
//@property (weak, nonatomic) IBOutlet UIButton *btntest;
//@property (weak, nonatomic) IBOutlet UILabel *lblcountdown;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *cardid;
@property long totalseconds;
@end
