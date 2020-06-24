//
//  DocumentListVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/16.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class DocumentListVC: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var documentTable: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender:UIRefreshControl){
        documentTable.reloadData()
        sender.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DocumentDataOperator.shared.getUidArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentDataCell", for: indexPath)

        let uidArray = DocumentDataOperator.shared.getUidArray()
        assert(indexPath.row < uidArray.count, "index is out of range uid array")
        
        let uid = uidArray[indexPath.row]
        
        guard let docInfo = DocumentDataOperator.shared.loadDocumentInfo(uid: uid) else{
            assert(false, "loaded document info class -> nil")
        }
        
        let img = DocumentDataOperator.shared.loadImageFromPath(filename: docInfo.imageFileName)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = img
        
        let explain = cell.viewWithTag(2) as! UILabel
        explain.text = docInfo.explain
        let savedDate = cell.viewWithTag(3) as! UILabel
        savedDate.text = docInfo.savedDate
        let path = cell.viewWithTag(4) as! UILabel
        path.text = docInfo.imageFileName
        
        let context = cell.viewWithTag(5) as! UITextView
        context.text = docInfo.context
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
        
        let uidArray = DocumentDataOperator.shared.getUidArray()
        assert(indexPath.row < uidArray.count, "index is out of range uid array")
        
        let uid = uidArray[indexPath.row]
        
        guard let docInfo = DocumentDataOperator.shared.loadDocumentInfo(uid: uid) else{
            assert(false, "loaded document info class -> nil")
        }
        
        let message = String(describing: docInfo.explain) + "\n" + String(describing: docInfo.savedDate)
        let alertController = UIAlertController(title:"確認メッセージ",message: message,preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "戻る", style: .default, handler: {action in print("back")})
        
        let okAction = UIAlertAction(title: "問題を解く", style: .default, handler: {action in
            print("go")
            let loadingScene = self.storyboard?.instantiateViewController(identifier: "LoadingSceneVC") as! LoadingSceneVC
            loadingScene.receivedTextFromPreScene = docInfo.context ?? ""
            loadingScene.modalPresentationStyle = .fullScreen
            self.present(loadingScene,animated: true,completion: nil)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController,animated: true,completion: nil)
    }
}
