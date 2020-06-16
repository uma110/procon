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
    
    private var settings: [String: Any] = [:]
    
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    
    private init() {}
    
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
    
    private func getDocumentsURL()->NSURL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        return documentsURL
    }
    
    private func fileInDocumentsDirectory(filename:String) -> String{
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL!.path
    }
    
    private func saveImage(image:UIImage,path:String) -> Bool{
        let jpgImageData = image.jpegData(compressionQuality: 1.0)
        do{
            try jpgImageData!.write(to: URL(fileURLWithPath: path),options: .atomic)
        }catch{
            print(error)
            return false
        }
        return true
    }
}

class DocumentInfo:NSCoder,NSCoding{
    var pathToDocument:String?
    var explain:String?
    var savedDate:String?
    override init(){
    }
    
    // デシリアライズ処理（デコード処理とも呼ばれる）
    required init?(coder aDecoder: NSCoder) {
        pathToDocument = aDecoder.decodeObject(forKey: "pathToDocument") as? String
        explain = aDecoder.decodeObject(forKey: "explain") as? String
        savedDate = aDecoder.decodeObject(forKey: "savedDate") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(pathToDocument,forKey: "pathToDocument")
        aCoder.encode(explain,forKey: "explain")
        aCoder.encode(savedDate,forKey: "savedDate")
    }
}
