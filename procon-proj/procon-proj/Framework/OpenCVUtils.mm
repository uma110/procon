//
//  OpenCVUtils.m
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/23.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

//#import <opencv2/opencv.hpp>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVUtils.h"

//OpenCVマネージャ
@implementation OpenCVUtils

//RGB→Gray
+ (UIImage*)rgb2binary:(UIImage *)image threshold:(int)threshold{
   cv::Mat img_Mat;
   UIImageToMat(image, img_Mat);
   cv::cvtColor(img_Mat, img_Mat, cv::COLOR_BGR2GRAY);
   return MatToUIImage(img_Mat);
}
@end
