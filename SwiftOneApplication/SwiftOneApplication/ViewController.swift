//
//  ViewController.swift
//  SwiftOneApplication
//
//  Created by zhengfeng on 17/3/24.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

import UIKit

struct RootStoryboard {
    static var LaunchKey:NSString { return "UILaunchStoryboardName"  }
    static var GuideKey:NSString  { return "UIGuideStoryboardName"   }
    static var LoginKey:NSString  { return "UILoginStoryboardName"   }
    static var MainKey:NSString   { return "UIMainStoryboardFile"    }
}

class ViewController: UIViewController {

    var launchVC:UIViewController?
    var guideVC:UIViewController?
    var loginVC:UIViewController?
    var mainVC:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func exitLogin() {
        
    }
    
    func login() {
        
    }
    
    
    
    
}

