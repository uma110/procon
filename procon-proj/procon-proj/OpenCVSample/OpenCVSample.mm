//
//  OpenCVSample.m
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/18.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import<opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVSample.h"

@implementation OpenCVSample

+(UIImage *)GrayScale:(UIImage *)image{
    // convert image to mat
    cv::Mat mat;
    UIImageToMat(image, mat);

    // convert mat to gray scale
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);

    // convert to image
    UIImage * grayImg = MatToUIImage(gray);

    return grayImg;
}

@end
