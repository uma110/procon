//
//  zikkenVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/18.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import Firebase

class zikkenVC: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var srcImage: UIImageView!
    @IBOutlet weak var dstImage: UIImageView!
    
    @IBOutlet weak var sliderValue: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func printCurrentUser(_ sender: Any) {
        let user = Auth.auth().currentUser
        print(user == nil)
        print(user?.email)
        print(user?.displayName)
        
        let scene = self.storyboard?.instantiateViewController(identifier: "AuthenticationVC") as! AuthenticationVC
        scene.modalPresentationStyle = .pageSheet
        self.present(scene,animated: true,completion: nil)
    }
    
    @IBAction func moveQuestionScene(_ sender: Any) {
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
    
    @IBAction func imageProcess(_ sender: Any) {
        guard let image = srcImage.image else{return}
        let threshold = Int32(sliderValue.value)
        print(threshold)
        self.dstImage.image = OpenCVUtils.rgb2binary(image, threshold: threshold)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage{
            srcImage.contentMode = .scaleAspectFit
            srcImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Canceled")
    }
    
    func imageProcess(){
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
