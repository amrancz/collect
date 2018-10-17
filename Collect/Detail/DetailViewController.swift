//
//  Detail.swift
//  Collect
//
//  Created by Adam Amran on 10/08/2018.
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

class DetailViewController: DetailViewControllerDraggable, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    var passedImage: UIImage!
    var passedScreenshotUUID: String?
    
    @IBOutlet weak var toolbarContainer: UIView!
    
    @IBOutlet weak var screenshotDetail: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        screenshotDetail.image = passedImage
        screenshotDetail.contentMode = .scaleAspectFit
        self.navigationController?.isNavigationBarHidden = true
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    var visible: Bool = true

    override var prefersStatusBarHidden: Bool {
        return !visible
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    @IBAction func hideUI() {
        if visible == true {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.visible = false
                self.view.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.toolbarContainer.isHidden = true
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.visible = true
                self.view.layer.backgroundColor = #colorLiteral(red: 0.9497935176, green: 0.9562532306, blue: 0.9594267011, alpha: 1)
                self.toolbarContainer.isHidden = false
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: nil)
        }
    }
    
    
    //MARK: Bottom toolbar
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var bottomToolbar: UIView!
    @IBOutlet weak var shareButton: NSLayoutConstraint!
    @IBOutlet weak var addTags: UIButton!
    
    let viewController = MainStoryboard.viewController.instantiate()
    let transitionDelegate = TagsModalTransitioningDelegate()
    
    @IBAction func openTags(_ sender: Any) {
        viewController.transitioningDelegate = self.transitionDelegate
        viewController.modalPresentationStyle = .custom
        viewController.passedScreenshotUUID = passedScreenshotUUID
        UIView.animate(withDuration: 0.3, animations: {
            self.present(self.viewController, animated: true, completion: nil)
        })
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

