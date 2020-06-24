//
//  AuthenticationVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/20.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class AuthenticationVC: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var currentUserState: UILabel!
    @IBOutlet weak var currentUserName: UILabel!
    @IBOutlet weak var currentUserEmail: UILabel!
    @IBOutlet weak var currentUserVerified: UILabel!
    
    func updateUserInfomation(){
        let user = Auth.auth().currentUser
        if user != nil{
            currentUserState.text = "ログイン中"
            currentUserName.text = user!.displayName
            currentUserEmail.text = user!.email
            currentUserVerified.text = user!.isEmailVerified ? "承認済み" : "未承認"
        }else{
            currentUserState.text = "ログインしていません"
            currentUserName.text = ""
            currentUserEmail.text = ""
            currentUserVerified.text = ""
        }
    }
    
    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    var handle:AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerName.delegate = self
        registerEmail.delegate = self
        registerPassword.delegate = self
        updateUserInfomation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if #available(iOS 13, *){
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        
        print("view will appear 2")
        handle = Auth.auth().addStateDidChangeListener{
            (auth,user) in
            print("state did change")
        }
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
        
        print("view will disppear 2")
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    private func getErrorMessage(of error:Error)->String{
        var message = "エラーが発生しました"
        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else{
            return message
        }
        
        switch errorCode{
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        // これは一例です。必要に応じて増減させてください。
        default:
            message = "特定外のエラー"
        }
        
        return message
    }
    
    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        // エラーがなければ何もしません
        guard let error = errorOrNil else { return }
        
        let message = getErrorMessage(of: error)
        
        // ここは後述しますが、とりあえず固定文字列
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func saveLoginUserInfo2Database(){
        guard let user = Auth.auth().currentUser else{
            print("user who will be saved is nil")
            return
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("userInfos").document(user.uid)
        ref.setData(
            ["name":user.displayName,
             "email":user.email
            ]
        )
        
    }
    
    @IBAction private func singUp(_ sender: Any) {
        let name = registerName.text ?? ""
        let email = registerEmail.text ?? ""
        let password = registerPassword.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password){
            [weak self] result,error in
            guard let self = self else{return}
            if let user = result?.user{
                let req = user.createProfileChangeRequest()
                req.displayName = name
                req.commitChanges(){[weak self] error in
                    guard let self = self else{return}
                    if error == nil{
                        user.sendEmailVerification(){
                            [weak self] error in
                            guard let self = self else{return}
                            if error == nil{
                                self.saveLoginUserInfo2Database()
                                AppUtils.alert(currentVC:self,title: "", message: "ユーザー登録完了しました\n登録されたメールアドレスに承認メッセージを送りました。\n承認しないと、ドキュメントの登録はできません")
                            }
                            self.showErrorIfNeeded(error)
                        }
                    }
                    self.showErrorIfNeeded(error)
                }
            }
            self.showErrorIfNeeded(error)
        }
    }
    
    @IBAction private func signIn(_ sender: Any) {
        let email = loginEmail.text ?? ""
        let password = loginPassword.text ?? ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult,error in
            guard let self = self else{return}
            if let user = authResult?.user{
                self.saveLoginUserInfo2Database()
                AppUtils.alert(currentVC:self,title: "", message: "ログインしました")
                self.updateUserInfomation()
            }
            self.showErrorIfNeeded(error)
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        try? Auth.auth().signOut()
        updateUserInfomation()
    }
}
