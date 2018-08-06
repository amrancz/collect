//
//  MainViewController.swift
//  Collect
//
//  Created by Adam Amran on 05/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import UIKit
import RealmSwift

class Screenshot: Object {
    @objc dynamic var screenshotID = ""
    @objc dynamic var screenshotTag: Tag?
}

class Tag: Object {
    @objc dynamic var tagName = ""
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))

    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}


