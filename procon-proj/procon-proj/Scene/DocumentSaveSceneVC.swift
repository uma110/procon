//
//  DocumentSaveSceneVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/17.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class DocumentSaveSceneVC: UIViewController,UIScrollViewDelegate,UITextFieldDelegate{
    @IBOutlet weak var header: UITextField!
    @IBOutlet weak var date: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var context: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var switchSavingLocal: UISwitch!
    @IBOutlet weak var switchSavingOnline: UISwitch!
    
    var receivedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeImage()
        initializeTextField()
        initializeScrollView()
    }
    
    func initializeImage(){
        if receivedImage != nil{
            imageView.image = receivedImage
        }else{
            imageView.image = UIImage(named:"noimage")
        }
    }
    
    func initializeTextField(){
        header.delegate = self
        date.delegate = self
        
        header.keyboardType = UIKeyboardType.default
        header.placeholder = "中学３年レベルの英文"
        
        date.keyboardType = UIKeyboardType.numbersAndPunctuation
        date.placeholder = "2020/06/17"
    }
    
    func initializeScrollView(){
        scrollView.delegate = self
        let screenSize:CGSize = UIScreen.main.bounds.size
        
        let padding = CGFloat(0)
        let scrollViewWidth = screenSize.width - padding*2
        scrollView.frame = CGRect(x:padding,y:30,width: scrollViewWidth, height: screenSize.height)
        
        scrollView.contentSize = CGSize(width: scrollViewWidth , height: screenSize.height * 1.1)
        
        scrollView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)) ,
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: self.view.window)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidHideNotification,
                                                  object: self.view.window)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("show")
        let info = notification.userInfo!
        
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let convertedTextFieldFrameBottom = self.view.convert(currentSelectedTextField.frame, from: scrollView).maxY
        
        // top of keyboard
        let topKeyboard = UIScreen.main.bounds.size.height - keyboardFrame.size.height
        // 重なり
        let distance = convertedTextFieldFrameBottom - topKeyboard
        
        let scrollOffset:CGFloat = 50
        if distance >= 0 {
            // scrollViewのコンテツを上へオフセット + 50.0(追加のオフセット)
            scrollView.contentOffset.y = distance + scrollOffset
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("hide")
        scrollView.contentOffset.y = 0
    }
    
    private var currentSelectedTextField:UITextField!
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("update")
        currentSelectedTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title:"確認メッセージ",message: "本当にデータを保存していいですか？",preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default, handler: {action in print("Cancel")})
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "ok", style: .default, handler: {action in print("OK")
            self.saveData()
        })
        alertController.addAction(okAction)
        
        self.present(alertController,animated: true,completion: nil)
    }
    
    func saveData(){
        let docInfo = DocumentInfo(explain: header.text, savedDate: date.text, context: context.text)
        let image = imageView.image
        if image == nil{
            DocumentDataOperator.shared.saveDocumentInfo(docInfo: docInfo)
        }else{
            DocumentDataOperator.shared.saveDocumentData(image: image!, docInfo: docInfo)
        }
    }
}
