//
//  TabController.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/17.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("tab pushed")
        switch item.tag{
        case 1:
            print("tag 1 view")
        case 2:
            print("tag 2 view")
        case 3:
            print("tag 3 view")
        default:
            break
        }
    }
}
