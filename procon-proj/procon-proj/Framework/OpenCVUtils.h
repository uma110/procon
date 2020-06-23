//
//  OpenCVUtils.h
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/23.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

#import <UIKit/UIKit.h>

//OpenCVマネージャ
@interface OpenCVUtils : NSObject
+ (UIImage*)rgb2binary:(UIImage*)image threshold:(int)threshold;
@end
