//
//  DocumentDataOperator.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/16.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import Foundation
import UIKit

final class DocumentDataOperator{
    //Singleton object
    public static let shared = DocumentDataOperator()
    
    private let userDefaults = UserDefaults.standard
    
    private static let DATA_UID_KEY = "DATA_UID_KEY"
    
    public func addUid(uid:String){
        var uidArray:[String]? = userDefaults.stringArray(forKey: DocumentDataOperator.DATA_UID_KEY)
        if uidArray != nil{
            uidArray?.append(uid)
            let newUidArray:Array = Array(Set(uidArray!))
            userDefaults.set(newUidArray, forKey: DocumentDataOperator.DATA_UID_KEY)
        }else{
            let newUidArray:[String] = [uid]
            userDefaults.set(newUidArray, forKey: DocumentDataOperator.DATA_UID_KEY)
        }
    }
    
    public func removeUid(uid:String){
        var uidArray:[String]? = userDefaults.stringArray(forKey: DocumentDataOperator.DATA_UID_KEY)
        if uidArray != nil{
            uidArray?.removeAll(where: {$0 == uid})
            userDefaults.set(uidArray, forKey: DocumentDataOperator.DATA_UID_KEY)
        }
    }
    
    public func getUidArray()->[String]{
        if let uidArray = userDefaults.stringArray(forKey: DocumentDataOperator.DATA_UID_KEY){
            return uidArray
        }else{
            return []
        }
    }
    
    private init() {}
    
    /*
    private var settings: [String: Any] = [:]
    
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    */
    
    /*
    ///Function to access private property from outside.
    public func string(forKey key: String) -> String? {
        var result: String?
        
        //Executed in serial queue that prevent errors even though set method and get method are called at the same time.
        self.concurrentQueue.sync {
            result = self.settings[key] as? String
        }
        return result
    }
    
    ///Function to access private property from outside.
    public func int(forKey key: String) -> Int? {
        var result: Int?
        
        //Executed in serial queue that prevent errors even though set method and get method are called at the same time.
        self.concurrentQueue.sync {
            result = self.settings[key] as? Int
        }
        return result
    }
    
    //Function to update private property from outside.
    public func set(value: Any, forKey key: String) {
        
        //The barriar ensures the queue does not start until all the previous blocks have been completed.
        self.concurrentQueue.async(flags: .barrier) {
            self.settings[key] = value
        }
    }
    */
    
    private func getDocumentsURL()->NSURL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        return documentsURL
    }
    
    public func fileInDocumentsDirectory(filename:String) -> String{
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL!.path
    }
    
    public func removeImage(filename:String)->Bool{
        do{
            try FileManager.default.removeItem(atPath: fileInDocumentsDirectory(filename: filename))
        }catch{
            print("remove error")
            return false
        }
        return true
    }
    
    public func saveImage(image:UIImage,filename:String) -> Bool{
        let path:String = fileInDocumentsDirectory(filename: filename)
        let jpgImageData = image.jpegData(compressionQuality: 1.0)
        do{
            try jpgImageData!.write(to: URL(fileURLWithPath: path),options: .atomic)
        }catch{
            print(error)
            return false
        }
        return true
    }
    
    public func loadImageFromPath(filename:String)->UIImage?{
        let path:String = fileInDocumentsDirectory(filename: filename)
        let image = UIImage(contentsOfFile: path)
        if image == nil{
            print("missing image at: \(path)")
        }
        return image
    }
    
    public func removeDocumentInfo(uid:String){
        userDefaults.removeObject(forKey: uid)
    }
    
    public func saveDocumentInfo(docInfo:DocumentInfo)->Bool{
        guard let archiveData = try? NSKeyedArchiver.archivedData(withRootObject: docInfo, requiringSecureCoding: true) else {
            fatalError("archive failed")
        }
        userDefaults.set(archiveData, forKey: docInfo.uid)
        return true
    }
    
    public func loadDocumentInfo(uid:String)->DocumentInfo?{
        if let loadedData = userDefaults.data(forKey: uid){
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedData) as? DocumentInfo
        }
        return nil
    }
    
    public func saveDocumentData(image:UIImage,docInfo:DocumentInfo){
        if !saveImage(image: image, filename: docInfo.imageFileName){
            print("save image succeed")
        }
        if !saveDocumentInfo(docInfo: docInfo){
            print("save document succeed")
        }
    }
}

class DocumentInfo:NSCoder,NSSecureCoding{
    static var supportsSecureCoding: Bool = true
    
    var uid:String
    var imageFileName:String
    var explain:String?
    var savedDate:String?
    var context:String?
    init(explain:String?,savedDate:String?,context:String?){
        self.uid = NSUUID().uuidString
        self.imageFileName = uid + ".jpg"
        self.explain = explain
        self.savedDate = savedDate
        self.context = context
    }
    
    // デシリアライズ処理（デコード処理とも呼ばれる）
    required init?(coder aDecoder: NSCoder) {
        uid = aDecoder.decodeObject(forKey: "uid") as! String
        imageFileName = aDecoder.decodeObject(forKey: "imageFileName") as! String
        explain = aDecoder.decodeObject(forKey: "explain") as? String
        savedDate = aDecoder.decodeObject(forKey: "savedDate") as? String
        context = aDecoder.decodeObject(forKey: "context") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid,forKey: "uid")
        aCoder.encode(imageFileName,forKey: "imageFileName")
        aCoder.encode(explain,forKey: "explain")
        aCoder.encode(savedDate,forKey: "savedDate")
        aCoder.encode(context,forKey: "context")
    }
}
