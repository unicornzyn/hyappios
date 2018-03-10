//
//  HYConfig.h
//  hyapp
//
//  Created by mac on 2018/1/27.
//  Copyright © 2018年 sequel. All rights reserved.
//


#ifndef HYConfig_h
#define HYConfig_h

//website=@"http://zshy.91huayi.com/";
//websitescan=@"http://app.kjpt.91huayi.com/";
//websitewxpay=@"http://pay.91huayi.com/";

#define MYTEST 1

#ifdef MYTEST

#define WEB_SITE        @"http://zshytest.91huayi.net/"
#define WEB_SITE_SCAN   @"http://mobile.kjpt.91huayi.com/"
#define WEB_SITE_WXPAY  @"http://zhifucme.91huayi.net/"
#define WEB_SITE_AI     @"http://hydbapp.91huayi.net/"

#else

#define WEB_SITE        @"http://zshy.91huayi.com/"
#define WEB_SITE_SCAN   @"http://app.kjpt.91huayi.com/"
#define WEB_SITE_WXPAY  @"http://pay.91huayi.com/"
#define WEB_SITE_AI     @"http://hydbapp.91huayi.net/"

#endif

#endif /* HYConfig_h */
