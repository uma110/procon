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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
}
