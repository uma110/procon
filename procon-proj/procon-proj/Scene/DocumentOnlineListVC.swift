//
//  FirstVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/15.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class DocumentOnlineListVC: UIViewController,UITableViewDataSource,UITableViewDelegate{
    var userInfos:[String:SimpleUserInfo] = [:]
    var dataArray:[DataForOnlineList] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.updateListCall(_:)), for: .valueChanged)
    }
    
    var count:Int = 0
    func updateList(){
        count += 1
        print("update"+String(count))
        userInfos = [:]
        dataArray = []
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("documents")
        
        let userRef = db.collection("userInfos")
        
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup){
            print("read user ref start")
            var isTaskFinished = false
            userRef.getDocuments(){(querySnapShot,error) in
                if let error = error {
                    print("error when getting document from online database : \(error)")
                } else{
                    for document in querySnapShot!.documents{
                        let user_uid = document.documentID
                        let data = document.data()
                        if let name = data["name"] as? String,let email = data["email"] as? String{
//                            print(name)
//                            print(email)
                            let userInfo = SimpleUserInfo(name: name, email: email)
                            self.userInfos[user_uid] = userInfo
                        }
                    }
                    isTaskFinished = true
                }
            }
            while !isTaskFinished{
                //                print("not finished1")
            }
            dispatchGroup.leave()
            print("read user ref finished")
        }
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup){
            print("read doc ref start")
            var isTaskFinished = false
            docRef.getDocuments(){(querySnapShot,error) in
                if let error = error {
                    print("error when getting document from online database : \(error)")
                } else{
                    for document in querySnapShot!.documents{
                        let user_uid = document.documentID
                        let data = document.data()
//                        print(user_uid)
                        for val in data.values{
                            if let docData = val as? Data{
                                if let docInfo = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(docData) as? DocumentInfo {
                                    let onlineListData:DataForOnlineList = DataForOnlineList(document: docInfo, user: self.userInfos[user_uid]!)
                                    self.dataArray.append(onlineListData)
                                }
                            }
                        }
                    }
                    isTaskFinished = true
                }
            }
            while !isTaskFinished{
                //                print("not finished2")
            }
            dispatchGroup.leave()
            print("read doc ref finished")
        }
        dispatchGroup.notify(queue: .main){
            print("all complete")
            for data in self.dataArray{
                let doc = data.document
                let user = data.user
                /*
                print(doc.explain ?? "nil")
                print(user.name)
                print(user.email)
                */
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        print("update finish"+String(count))
    }
    
    @objc func updateListCall(_ sender:UIRefreshControl){
        updateList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "docListCell", for: indexPath)
        
        assert(indexPath.row < dataArray.count, "index is out of range uid array")
        
        let data = dataArray[indexPath.row]
        let docInfo:DocumentInfo = data.document
        let userInfo:SimpleUserInfo = data.user
        
        let name = cell.viewWithTag(1) as! UILabel
        name.text = userInfo.name
        let email = cell.viewWithTag(2) as! UILabel
        email.text = userInfo.email
        let title = cell.viewWithTag(3) as! UILabel
        title.text = docInfo.explain
        let savedDate = cell.viewWithTag(4) as! UILabel
        savedDate.text = docInfo.savedDate
        
        let context = cell.viewWithTag(5) as! UITextView
        context.text = docInfo.context
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
        
        assert(indexPath.row < dataArray.count, "index is out of range uid array")
        
        let docInfo:DocumentInfo = dataArray[indexPath.row].document
        let userInfo:SimpleUserInfo = dataArray[indexPath.row].user
        
        let message = userInfo.name + "\n" + userInfo.email + "\n" + String(describing: docInfo.explain) + "\n" + String(describing: docInfo.savedDate)
        
        let alertController = UIAlertController(title:"確認メッセージ",message: message,preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "戻る", style: .default, handler: {action in print("back")})
        
        let okAction = UIAlertAction(title: "問題を解く", style: .default, handler: {action in
            print("go")
            let questionScene = self.storyboard?.instantiateViewController(identifier: "QuestionSceneVC") as! QuestionSceneVC
            questionScene.modalPresentationStyle = .fullScreen
            self.present(questionScene,animated: true,completion: nil)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController,animated: true,completion: nil)
    }
}

struct DataForOnlineList{
    var document:DocumentInfo
    var user:SimpleUserInfo
}

struct SimpleUserInfo{
    var name:String
    var email:String
}
