//
//  ViewController.m
//  扫描二维码
//
//  Created by 王亮 on 2016/10/20.
//  Copyright © 2016年 wangliang. All rights reserved.
//

#import "ViewController.h"
#import "MyViewController.h"
#import "ZXingObjC.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) AVCaptureSession *session;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic,strong) UIImagePickerController *imagePickerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor orangeColor];
    
//    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(30, 100, 80, 50)];
//    btn.backgroundColor=[UIColor blueColor];
//    [btn setTitle:@"相册" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    [self.view addSubview:btn];
    
    //initWithTitle:(nullable NSString *)title style:(UIBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action;
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(btnClick)];
    
     [self imageCapture];
    
}

-(void)btnClick{
    
    NSLog(@"btnClick--");
    
    //判断是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        return;
    }
    
    UIImagePickerController *imagePickerController =[[UIImagePickerController alloc] init];
   
    imagePickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePickerController.delegate=self;
    
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    self.imagePickerController=imagePickerController;
}

#pragma mark -- UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    NSLog(@"info=%@--picker=%@",info,picker);
    /*
     UIImagePickerControllerMediaType = "public.image";
     UIImagePickerControllerOriginalImage = "<UIImage: 0x170093b50> size {750, 1334} orientation 0 scale 1.000000";
     UIImagePickerControllerReferenceURL = "assets-library://asset/asset.PNG?id=3A2B0EA1-E846-46D4-A02E-4A0D86813676&ext=PNG";
     */
    
    UIImage *image=info[UIImagePickerControllerOriginalImage];
  
    NSLog(@"image=%@",image);
    
    //1.苹果原生
    [self scanQRCode:image];
    
    //2.ZXingObjC
//    [self getURLWithImage:image];
    
    //3.Zbar
}

//苹果原生
- (void)scanQRCode:(UIImage *)image {
    
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    for (int index = 0; index < [features count]; index ++)
    {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        NSLog(@"result:%@",scannedResult);
        
        [self loadWebViewWithURL:scannedResult];
    }
}


//获取图片二维码对应的URL
-(void)getURLWithImage:(UIImage *)image{
    
    CGImageRef imageToDecode = image.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    
    ZXBinaryBitmap *bitmap=[ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXBinarizer binarizerWithSource:source]];
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    NSError *error = nil;

    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (result) {
        NSLog(@"result=%@",result);
        NSString *contents = result.text;
        NSLog(@"contents=%@",contents);
    }else {
        
        NSLog(@"result为空");
    }
}


-(void)imageCapture
{
    //捕捉会话创建
    AVCaptureSession *session=[[AVCaptureSession alloc] init];
    
    //输入设备
    AVCaptureDevice *device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error=nil;
    AVCaptureDeviceInput *input=[AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    NSLog(@"error=%@",error);
    [session addInput:input];
    
    //输出数据
    AVCaptureMetadataOutput *output=[[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    NSLog(@"output001=%@",output);
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    NSLog(@"output002=%@",output);
    
    //扫描图层
    AVCaptureVideoPreviewLayer *layer=[AVCaptureVideoPreviewLayer layerWithSession:session];
    
    layer.frame=self.view.bounds;
    [self.view.layer addSublayer:layer];
    
    //开始扫描
    [session startRunning];
    
    self.session=session;
    self.layer=layer;

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
    
}

#pragma mark -- AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"metadataObjects=%@-connection=%@",metadataObjects,connection);
    
    /*
     "<AVMetadataMachineReadableCodeObject: 0x174220ee0, type=\"org.iso.QRCode\", bounds={ 0.4,0.4 0.2x0.4 }>corners { 0.4,0.8 0.6,0.8 0.6,0.4 0.4,0.4 }, time 324540933846750, stringValue \"https://item.taobao.com/item.htm?id=536670503340\""
     )-
     connection=<AVCaptureConnection: 0x17001ec80 [type:mobj][enabled:1][active:1]>
     */
    
    if (metadataObjects.count>0) {
        
        NSLog(@"扫描到数据--");
    
        //获取扫描结果
        AVMetadataMachineReadableCodeObject *object=[metadataObjects lastObject];
        
        
        [self loadWebViewWithURL:object.stringValue];
        
    }else
    {
        NSLog(@"没有扫描到数据");
    }
}

//打开连接对应页面
-(void)loadWebViewWithURL:(NSString *)stringUrl
{
    MyViewController *myVc=[[MyViewController alloc] init];
    myVc.urlString=stringUrl;
    
    NSLog(@"stringUrl=%@",stringUrl);
    [self.navigationController pushViewController:myVc animated:YES];
    
    
    [self.session stopRunning];
    //移除图层
    [self.layer removeFromSuperlayer];
}

@end
