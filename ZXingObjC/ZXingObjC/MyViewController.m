//
//  MyViewController.m
//  扫描二维码
//
//  Created by 王亮 on 2016/10/20.
//  Copyright © 2016年 wangliang. All rights reserved.
//

#import "MyViewController.h"
#import <WebKit/WebKit.h>

@interface MyViewController ()

@property (nonatomic,strong) UIWebView *webView;


@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       
    self.view.backgroundColor=[UIColor redColor];
    
    WKWebView *wkWebView=[[WKWebView alloc] initWithFrame:self.view.bounds];
    
    NSURL *url=[NSURL URLWithString:_urlString];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [wkWebView loadRequest:request];
    
    [self.view addSubview:wkWebView];
}

-(void)test01
{
    UIWebView *webView=[[UIWebView alloc] initWithFrame:self.view.bounds];
    
    
    NSURL *url=[NSURL URLWithString:self.urlString];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    self.webView=webView;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
