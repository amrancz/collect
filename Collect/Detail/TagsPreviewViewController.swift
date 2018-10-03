//
//  TagsPreviewViewController.swift
//  Collect
//
//  Created by Adam Amran on 31/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit
import Realm


private struct MainStoryboard: StoryboardType {
    static let name = "Main"
    static let viewController = StoryboardReference<MainStoryboard, TagsModalViewController>(id: "TagsModalViewControllerID")
}

class TagsPreviewViewController: UIViewController {
    
    let viewController = MainStoryboard.viewController.instantiate()
    let transitionDelegate = TagsModalTransitioningDelegate()
    
    var passedScreenshotUUID: String?
    
    @IBOutlet var tagsPreview: UIView!
    
    @IBOutlet weak var addTags: UIButton!
    @IBAction func openTags(_ sender: Any) {
        viewController.transitioningDelegate = self.transitionDelegate
        viewController.modalPresentationStyle = .custom
        viewController.passedScreenshotUUID = passedScreenshotUUID
        UIView.animate(withDuration: 0.3, animations: {
            self.present(self.viewController, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        tagsPreview.layer.shadowColor = UIColor.black.cgColor
        tagsPreview.layer.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9490196078, alpha: 1)
        tagsPreview.layer.shadowRadius = 8
        tagsPreview.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        tagsPreview.layer.shadowOpacity = 0.3
        tagsPreview.layer.cornerRadius = 10
        tagsPreview.layer.masksToBounds = false
        tagsPreview.clipsToBounds = false
    }
}
