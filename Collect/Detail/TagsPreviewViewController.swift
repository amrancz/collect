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
import RealmSwift


private struct MainStoryboard: StoryboardType {
    static let name = "Main"
    static let viewController = StoryboardReference<MainStoryboard, TagsModalViewController>(id: "TagsModalViewControllerID")
}

class TagsPreviewViewController: UIViewController {
    
    let viewController = MainStoryboard.viewController.instantiate()
    let transitionDelegate = TagsModalTransitioningDelegate()
    
    var passedImage: UIImage!
    var passedScreenshotUUID: String?
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var tagsPreview: UIView!
    @IBOutlet weak var shareButton: NSLayoutConstraint!
    
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
        tagsPreview.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
//        tagsPreview.layer.shadowRadius = 8
//        tagsPreview.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
//        tagsPreview.layer.shadowOpacity = 0.3
//        tagsPreview.layer.cornerRadius = 10
        tagsPreview.layer.masksToBounds = false
        tagsPreview.clipsToBounds = false
    }
    @IBAction func shareScreenshot(_ sender: Any) {
        let imageToShare = [ passedImage! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true) {
        }
    }
    
    @IBAction func deleteScreenshot(_ sender: Any) {
        let deleteAction = UIAlertAction(title: "Delete screenshot", style: .destructive){ (action:UIAlertAction!) in
            let realm = try! Realm()
            let screenshot = realm.objects(Screenshot.self).filter("screenshotID = '\(self.passedScreenshotUUID!)'")
            try! realm.write {
                realm.delete(screenshot)
            }
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadCollection"), object: nil))
            self.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
        }
        let deleteScreenshotAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        deleteScreenshotAlert.addAction(deleteAction)
        deleteScreenshotAlert.addAction(cancelAction)
        self.present(deleteScreenshotAlert, animated: true) {
        }
    }
}
