//
//  ViewController.m
//  图片上传处理
//
//  Created by 杨林贵 on 17/2/20.
//  Copyright © 2017年 杨林贵. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageV1;

@property (weak, nonatomic) IBOutlet UIImageView *imageV2;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //参考：http://www.jb51.net/article/89491.htm
    /*
     
     1、确图片的压缩的概念：
     “压” 是指文件体积变小，但是像素数不变，长宽尺寸不变，那么质量可能下降。
     “缩” 是指文件的尺寸变小，也就是像素数减少，而长宽尺寸变小，文件体积同样会减小。
     */
//    
    UIActionSheet *actionSheet  =[[UIActionSheet alloc] initWithTitle:@"图片压缩" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [actionSheet showInView:self.view];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIActionSheet *actionSheet  =[[UIActionSheet alloc] initWithTitle:@"图片压缩" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [actionSheet showInView:self.view];

}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *picVc = [[UIImagePickerController alloc] init];
            picVc.delegate = self;
            //拍照
            picVc.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picVc animated:YES completion:nil];
        }
        

    }else if (buttonIndex ==1){
    
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            UIImagePickerController *picVc = [[UIImagePickerController alloc] init];
            picVc.delegate = self;
            //相册选择
            picVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picVc animated:YES completion:nil];
        }

    }
   
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];

    UIImage *imaged = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageV1.image = imaged;
    NSData *imageData = UIImageJPEGRepresentation(imaged, 1.0);
    NSLog(@"imageData:%zd",imageData.length);

    //这里保证图片清晰，500的宽差不多
   [self image2WithImg:imaged andImageWidth:500];
    
}

//处理方式：先“压”后”缩“
-(void)image2WithImg:(UIImage *)imaged andImageWidth:(CGFloat)imageWidth
{
    //487927   先压，经过这一步后，图片的size其实没有改变的，再缩后才变。
    NSData *imgData = UIImageJPEGRepresentation(imaged, 0.5);
    imaged = [UIImage imageWithData:imgData];
    
    
    CGFloat height = imageWidth*(imaged.size.height/imaged.size.width);
    
    UIImage *newImage = [self imageByScalingAndCroppingForSize:CGSizeMake(imageWidth, height) withSourceImage:imaged];
    
    NSData *newImageData = UIImageJPEGRepresentation(newImage, 1.0); //488702
    
    
    NSLog(@"newImageData2:%zd",newImageData.length);
    self.imageV2.image = newImage;

    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"image22"];
    [newImageData writeToFile:path atomically:YES];

}

//这个方法可以封装一下，抽离出来
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        //  CGFloat widthFactor = targetWidth / width;
        
         CGFloat widthFactor = targetWidth/ width;
         CGFloat heightFactor  =targetHeight/height;
        
        if (widthFactor>heightFactor) {
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight-scaledHeight)*0.5;
        }else
        {
            thumbnailPoint.x = (targetWidth -scaledWidth)*0.5;
        }
        
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    {
        NSLog(@"image error");
    }
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
