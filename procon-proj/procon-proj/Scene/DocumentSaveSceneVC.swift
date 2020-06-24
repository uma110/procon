//
//  DocumentSaveSceneVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/17.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class DocumentSaveSceneVC: UIViewController,UIScrollViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate{
    @IBOutlet weak var header: UITextField!
    @IBOutlet weak var date: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var context: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var switchSavingLocal: UISwitch!
    @IBOutlet weak var switchSavingOnline: UISwitch!
    
    var receivedImage:UIImage?
    
    var receivedTextFromPreScene:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        context.delegate = self
        context.text = receivedTextFromPreScene
        initializeImage()
        initializeTextField()
        initializeScrollView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(_ sender:UITapGestureRecognizer){
        print("tap")
        let tapPoint = sender.location(in: self.view)
        print("x y -> \(tapPoint.x) \(tapPoint.y)")
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
        header.attributedPlaceholder = NSAttributedString(string: "例:英語論文のアブストラクト１", attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        
        date.keyboardType = UIKeyboardType.numbersAndPunctuation
        date.attributedPlaceholder = NSAttributedString(string: "例:2020/06/17", attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
    }
    
    func initializeScrollView(){
        scrollView.delegate = self
        let screenSize:CGSize = UIScreen.main.bounds.size
        
        let padding = CGFloat(0)
        let scrollViewWidth = screenSize.width - padding*2
        scrollView.frame = CGRect(x:padding,y:0,width: scrollViewWidth, height: screenSize.height)
        
        scrollView.contentSize = CGSize(width: scrollViewWidth , height: screenSize.height * 1.1)
        
        scrollView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if #available(iOS 13, *){
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        print("view will appear")
        registerObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13, *){
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        if #available(iOS 13, *){
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
        print("view will disppear")
        resetObserver()
    }
    
    func registerObserver(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)) ,
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    func resetObserver(){
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidHideNotification,
                                                  object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        print("show")
        let info = notification.userInfo!
        
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        print(currentSelectedTextInputFrame)
        let convertedTextFieldFrameBottom = self.view.convert(currentSelectedTextInputFrame!, from: scrollView).maxY
        print(convertedTextFieldFrameBottom)
        // top of keyboard
        var modalHeightDiff = CGFloat(0)
        if self.modalPresentationStyle == .pageSheet {
            modalHeightDiff = CGFloat(30)
        }
        print(modalHeightDiff)
        let topKeyboard = UIScreen.main.bounds.size.height - keyboardFrame.size.height-modalHeightDiff
        print(topKeyboard)
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
    
    private var currentSelectedTextInputFrame:CGRect?
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("update")
        currentSelectedTextInputFrame = textView.frame
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("update")
        currentSelectedTextInputFrame = textField.frame
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if !switchSavingLocal.isOn && !switchSavingOnline.isOn {
            AppUtils.alert(currentVC: self, title: "", message: "ローカルに保存、もしくはオンライン共有、最低一つ以上選択して下さい")
            return
        }
        if(switchSavingOnline.isOn){
            guard let user = Auth.auth().currentUser else{
                AppUtils.alert(currentVC: self, title: "", message: "データをオンライン共有するには、ログインしてください")
                return
            }
            if !user.isEmailVerified{
                AppUtils.alert(currentVC: self, title: "", message: "データをオンラインにアップロードするには、お使いのユーザーアカウントのメール認証をしてください")
                return
            }
        }
        
        var message:String = "本当にデータを保存していいですか？"
        if switchSavingLocal.isOn{
            message += "\nローカル:○"
        }else{
            message += "\nローカル:×"
        }
        if switchSavingOnline.isOn{
            message += "\nオンライン:○"
        }else{
            message += "\nオンライン:×"
        }
        let alertController = UIAlertController(title:"確認メッセージ",message:message,preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default, handler: {action in print("Cancel")})
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "ok", style: .default, handler: {action in print("OK")
            
            if self.switchSavingLocal.isOn{
                self.saveData2Local()
            }
            
            if self.switchSavingOnline.isOn{
                self.saveData2Online()
            }
        })
        alertController.addAction(okAction)
        
        self.present(alertController,animated: true,completion: nil)
    }
    
    func saveData2Local(){
        let docInfo = DocumentInfo(explain: header.text, savedDate: date.text, context: context.text)
        let image = imageView.image
        DocumentDataOperator.shared.addUid(uid: docInfo.uid)
        if image == nil{
            DocumentDataOperator.shared.saveDocumentInfo(docInfo: docInfo)
        }else{
            DocumentDataOperator.shared.saveDocumentData(image: image!, docInfo: docInfo)
        }
    }
    
    @IBAction func moveAuthScene(_ sender: Any) {
        let authScene = self.storyboard?.instantiateViewController(identifier: "AuthenticationVC") as! AuthenticationVC
        authScene.modalPresentationStyle = .pageSheet
        resetObserver()
        self.present(authScene,animated: true,completion: nil)
    }
    
    func saveData2Online(){
        guard let user = Auth.auth().currentUser else{
            AppUtils.alert(currentVC: self, title: "", message: "データをオンライン共有するには、ログインしてください")
            return
        }
        
        let docInfo = DocumentInfo(explain: header.text, savedDate: date.text, context: context.text)
        
        let db = Firestore.firestore()
        let ref = db.collection("documents").document(user.uid)
 
        guard let archiveData = try? NSKeyedArchiver.archivedData(withRootObject: docInfo, requiringSecureCoding: true) else {
            fatalError("archive failed")
        }
        
        ref.setData([docInfo.uid:archiveData],merge: true){
            error in
            if let error = error{
                print("Error adding document : \(error)")
                return
            }
            print("data save ok")
            AppUtils.alert(currentVC: self, title: "", message: "ドキュメントデータをオンラインにアップロードしました。")
        }
    }
}
