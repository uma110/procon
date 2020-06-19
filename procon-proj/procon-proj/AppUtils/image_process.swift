//
//  image_process.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/18.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import Foundation
import CoreImage

class CustomBinaryFilter:CIFilter{
    private let kernel: CIColorKernel
    
    var inputImage: CIImage?
    
    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIColorKernel(functionName: "customBinaryFilter", fromMetalLibraryData: data)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func outputImage() -> CIImage? {
        print("step1")
        guard let inputImage = inputImage else {return nil}
        print("step2")
        return kernel.apply(extent: inputImage.extent, arguments: [inputImage])
    }
}

class ImageProcess{
    static func image2Binary(image:UIImage) -> UIImage{
        var r:[CGFloat] = []
        var g:[CGFloat] = []
        var b:[CGFloat] = []
        var a:[CGFloat] = []
        
        if let pixelBuffer = PixelBuffer(uiImage: image){
            for x in 0..<pixelBuffer.width {
                for y in 0..<pixelBuffer.height {
                    r.append(pixelBuffer.getRed(x: x, y: y))
                    g.append(pixelBuffer.getBlue(x: x, y: y))
                    b.append(pixelBuffer.getGreen(x: x, y: y))
                    a.append(pixelBuffer.getAlpha(x: x, y: y))
                }
            }
        }else{
            print("image not format")
        }
        print("create complete")
        return image.createBinarizedImage(r: r, g: g, b: b, a: a)
    }
}

class PixelBuffer {
    private var pixelData: Data
    var width: Int
    var height: Int
    private var bytesPerRow: Int
    private let bytesPerPixel = 4 //1ピクセルが4バイトのデータしか扱わない

    init?(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage,
            //R,G,B,A各8Bit
            cgImage.bitsPerComponent == 8,
            //1 pixelが32bit
            cgImage.bitsPerPixel == bytesPerPixel * 8 else {
                return nil
                
        }
        pixelData = cgImage.dataProvider!.data! as Data
        width = cgImage.width
        height = cgImage.height
        bytesPerRow = cgImage.bytesPerRow
    }

    func getRed(x: Int, y: Int) -> CGFloat {
        let pixelInfo = bytesPerRow * y + x * bytesPerPixel
        let r = CGFloat(pixelData[pixelInfo]) / CGFloat(255.0)
        
        return r
    }
    func getGreen(x: Int, y: Int) -> CGFloat {
        let pixelInfo = bytesPerRow * y + x * bytesPerPixel
        let green = CGFloat(pixelData[pixelInfo+1]) / CGFloat(255.0)
        
        return green
    }
    func getBlue(x: Int, y: Int) -> CGFloat {
        let pixelInfo = bytesPerRow * y + x * bytesPerPixel
        let blue = CGFloat(pixelData[pixelInfo+2]) / CGFloat(255.0)
        
        return blue
    }
    func getAlpha(x: Int, y: Int) -> CGFloat {
        let pixelInfo = bytesPerRow * y + x * bytesPerPixel
        let alpha = CGFloat(pixelData[pixelInfo+3]) / CGFloat(255.0)
        return alpha
    }
}

extension UIImage {
    func createBinarizedImage(r:[CGFloat], g: [CGFloat], b:[CGFloat], a:[CGFloat]) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let wid:Int = Int(size.width)
        let hei:Int = Int(size.height)
        let threshold:CGFloat = 128/255
        print(wid)
        print(hei)
        for w in 0..<wid {
            for h in 0..<hei {
                let index = (w * wid) + h
                var color = 0.2126 * r[index] + 0.7152 * g[index] + 0.0722 * b[index]
                if color > threshold {
                    color = 255
                } else {
                    color = 0
                }
                UIColor(red: color, green: color, blue: color, alpha: a[index]).setFill()
                let drawRect = CGRect(x: w, y: h, width: 1, height: 1)
                UIRectFill(drawRect)
                draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
            }
        }
        let binarizeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        print("binarize image")
        return binarizeImage
    }
}
