//
//  MainSceneVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/17.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class MainSceneVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("main")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("main view appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("main view disppear")
    }
}
