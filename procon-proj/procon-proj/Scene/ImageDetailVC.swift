//
//  ImageDetailVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/15.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import FirebaseMLVision

class ImageDetailVC: UIViewController {

    var targetImage:UIImage = UIImage()
            
    @IBOutlet weak var sentenceView: UITextView!
    
    let vision = Vision.vision()
    override func viewDidLoad() {
        super.viewDidLoad()
        labelInit()
        updateSentenceView("text field for recognized text")
    }
    
    func labelInit(){
        let label1 = UILabel()
        let label2 = UILabel()
        let uiScreen = UIScreen.main.bounds
        let windowScreen = self.view.bounds
        let labelWidthSize:CGFloat = CGFloat(100)
        label1.frame = CGRect(x: uiScreen.width/2-labelWidthSize/2, y: 50, width: labelWidthSize, height: 50)
        label1.text = "label1"
        label1.backgroundColor = UIColor.lightGray
        label2.frame = CGRect(x: windowScreen.width/2-labelWidthSize, y: 100, width: labelWidthSize, height: 50)
        label2.text = "label2"
        label2.backgroundColor = UIColor.darkGray
        
        self.view.addSubview(label1)
        self.view.addSubview(label2)
    }
    
    @IBAction func Start(_ sender: Any) {
        
        let textRecognizer = vision.onDeviceTextRecognizer()
        let image = VisionImage(image: targetImage)
        
        textRecognizer.process(image){
            result,error in
            guard error == nil,let result = result else{
                print("recognizer failed")
                self.updateSentenceView("failed to recognize text from image")
                return
            }
            let resultText = result.text
            var recognizedSentence:String = ""
            for block in result.blocks {
                let blockText = block.text
                recognizedSentence+=blockText + " "
                /*
                let blockConfidence = block.confidence
//                let blockLanguages = block.recognizedLanguages
//                let blockCornerPoints = block.cornerPoints
//                let blockFrame = block.frame
                print("block")
                print(blockText)
                print(blockConfidence)
                for line in block.lines {
                    let lineText = line.text
                    let lineConfidence = line.confidence
//                    let lineLanguages = line.recognizedLanguages
//                    let lineCornerPoints = line.cornerPoints
//                    let lineFrame = line.frame
                    print("line")
                    print(lineText)
                    print(lineConfidence)
                    for element in line.elements {
                        let elementText = element.text
                        let elementConfidence = element.confidence
//                        let elementLanguages = element.recognizedLanguages
//                        let elementCornerPoints = element.cornerPoints
//                        let elementFrame = element.frame
                        print("element")
                        print(elementText)
                        print(elementConfidence)
                    }
                }
            */
            }
            /*
            print("======= result text ======")
            print(resultText)
            print("======= recognized sentence =====")
            print(recognizedSentence)
            */
            let sentence = "===== result text =====\n" + resultText + "\n\n===== recognized sentence =====\n" + recognizedSentence
            self.updateSentenceView(sentence)
        }
    }
    func updateSentenceView(_ sentence:String){
        sentenceView.text = sentence
    }
}
