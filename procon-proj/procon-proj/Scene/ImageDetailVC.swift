//
//  ImageDetailVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/15.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import FirebaseMLVision

class DocumentLoadSceneVC: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    var targetImage:UIImage?
        
    @IBOutlet weak var readImage: UIImageView!
    
    @IBOutlet weak var sentenceView: UITextView!
    
    let vision = Vision.vision()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sentenceView.textColor = UIColor.black
        updateSentenceView("text field for recognized text")
        
        let screen = UIScreen.main.bounds.size
        print(screen)
        readImage.center = CGPoint(x: screen.width/4, y: screen.height / 4 * 3)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTap(_:)))
        gesture.delegate = self
        readImage.addGestureRecognizer(gesture)
    }
    
    var isScaleUp:Bool = false
    let defaultScaleUpValue = CGFloat(3)
    @objc func imageTap(_ sender:UITapGestureRecognizer){
        let screen = UIScreen.main.bounds.size
        print(screen)
        var position:CGPoint
        var scale:CGFloat = 1
        if isScaleUp{
            position = CGPoint(x: screen.width/4, y: screen.height / 4 * 3)
            scale /= defaultScaleUpValue
            isScaleUp = !isScaleUp
        }else{
            position = CGPoint(x: screen.width/2, y: screen.height/2)
            scale *= defaultScaleUpValue
            isScaleUp = !isScaleUp
        }
        
        let rect = readImage.frame
        readImage.frame = CGRect(x: 0, y: 0, width: rect.width * scale, height: rect.height * scale)
        readImage.center = position
    }
    
    @IBAction func extractButtonTapped(_ sender: Any) {
        if targetImage != nil{
            extractTextFromImage(targetImage!)
        }else{
            print("target image -> nil")
        }
    }
    
    func extractTextFromImage (_ target:UIImage){
        let textRecognizer = vision.onDeviceTextRecognizer()
        let image = VisionImage(image: target)
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
    
    @IBAction func takePicture(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }else{
            print("error")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage{
            readImage.contentMode = .scaleAspectFit
            readImage.image = pickedImage
            targetImage = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Canceled")
    }
    
    @IBAction func selectImageFromCameraroll(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }else{
            print("error")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let nextScene = self.storyboard?.instantiateViewController(identifier: "DocumentSaveSceneVC") as! DocumentSaveSceneVC
        nextScene.receivedImage = readImage.image
        self.present(nextScene,animated: true,completion: nil)
    }
}
