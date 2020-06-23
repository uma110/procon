//
//  AppUtils.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/16.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import Foundation

class AppUtils{
    static func alert(currentVC:UIViewController,title:String, message:String) {
        let alertController = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
        currentVC.present(alertController, animated: true)
    }
}
