//
//  FirstVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/15.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class FirstVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }else{
            label.text = "error"
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage{
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        label.text = "Tap the [Save] to save a pickture"
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        label.text = "Canceled"
    }
    
    @IBAction func savePicture(_ sender: Any) {
        let image:UIImage! = cameraView.image
        
        if image != nil{
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }else{
            label.text = "image Failed !"
        }
    }
    
    @objc func image(_ image:UIImage,didFinishSavingWithError error:NSError!,contextInfo:UnsafeMutableRawPointer){
        if error != nil{
            print(error.code)
            label.text = "Save Failed !"
        }else{
            label.text = "Save succeeded"
        }
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
            label.text = "Tap the [Start] to save a picture"
        }else{
            label.text = "error"
        }
    }
    
    @IBAction func processStart(_ sender: Any) {
        let nextScene = self.storyboard?.instantiateViewController(identifier: "ImageDetailVC") as! ImageDetailVC
        var canPreparedImage:Bool = false
        if cameraView != nil{
            if cameraView.image != nil{
                nextScene.targetImage = cameraView.image!
                canPreparedImage = true
            }else{
                print("image -> nil")
            }
        }else{
            print("imageView -> nil")
        }
        
        if canPreparedImage {
//            nextScene.modalPresentationStyle = .fullScreen
            self.present(nextScene,animated: true,completion: nil)
        }
    }
}
