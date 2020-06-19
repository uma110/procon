//
//  zikkenVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/18.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class zikkenVC: UIViewController {

    @IBOutlet weak var srcImage: UIImageView!
    @IBOutlet weak var dstImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func moveQuestionScene(_ sender: Any) {
        let questionScene = self.storyboard?.instantiateViewController(identifier: "QuestionSceneVC") as! QuestionSceneVC
        questionScene.questions = ["aaa","aa","aty"]
        questionScene.answers = ["siij","jiaji","iajig"]
        questionScene.modalPresentationStyle = .fullScreen
        self.present(questionScene,animated: true,completion: nil)
    }
    
    @IBAction func imageProcess(_ sender: Any) {
        /*
        let filter = CIFilter(name: "CIPhotoEffectMono")!
        
        let inputImage = CIImage(image: srcImage.image!)
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        dstImage.image = UIImage(ciImage: filter.outputImage!)
 */
        let inputImage = CIImage(image: srcImage.image!)
        
        let filter = CustomBinaryFilter()
        
        filter.inputImage = inputImage!
        
        print(inputImage != nil)
        
        let image:CIImage? = filter.outputImage()
        if image == nil{
            return
        }
        
        dstImage.image = UIImage(ciImage: image!)
    }
}
