//
//  metalSetting.metal
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/18.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/Coreimage.h>

extern "C" { namespace coreimage {
    
    half4 customBinaryFilter(sample_h sample) {
        half4 color = sample.rgba;
        
        half3 checkColor = round(linear_to_srgb(color.rgb) * 255);
        
        half3 convertColor = half3(255.0/255.0, 128.0/255.0, 20.0/255.0);
        
        if ((checkColor.r == 128) && (checkColor.g == 128) && (checkColor.b == 128)) {
            color = half4(srgb_to_linear(convertColor), 1.0);
        }
        
        return color;
  }
}}
