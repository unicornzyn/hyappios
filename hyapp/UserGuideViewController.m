//
//  UserGuideViewController.m
//  hyapp
//
//  Created by mac on 2016/9/24.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import "UserGuideViewController.h"
#import "ViewController.h"
@interface UserGuideViewController ()

@end

@implementation UserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initGuid];
}

-(void)initGuid{
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width*4, 0)];
    
    UIImageView *imgview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [imgview1 setImage:[UIImage imageNamed:@"page1.png"]];
    [scrollView addSubview:imgview1];
    
    UIImageView *imgview2=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [imgview2 setImage:[UIImage imageNamed:@"page2.png"]];
    [scrollView addSubview:imgview2];
    
    UIImageView *imgview3=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*2, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [imgview3 setImage:[UIImage imageNamed:@"page3.png"]];
    [scrollView addSubview:imgview3];
    
    UIImageView *imgview4=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*3, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [imgview4 setImage:[UIImage imageNamed:@"page4.png"]];
    imgview4.userInteractionEnabled=YES;
    [scrollView addSubview:imgview4];
    scrollView.delegate=self;
    
    /*
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//在imageview3上加载一个透明的button
     [button setTitle:nil forState:UIControlStateNormal];
     [button setFrame:CGRectMake(46, 371, 230, 37)];
     [button addTarget:self action:@selector(firstpressed) forControlEvents:UIControlEventTouchUpInside];
    [imageview3 addSubview:button];
     */
    
    [self.view addSubview:scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    CGFloat currentOffset = offset.x + bounds.size.width - inset.right;
    CGFloat maximumOffset = size.width;
    BOOL isstart=false;
    if(!isstart&&currentOffset>=maximumOffset){
        isstart=true;
        ViewController *vc = [[ViewController alloc] init];
        self.view.window.rootViewController = vc;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
