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
import ImageSlideshow

private struct MainStoryboard: StoryboardType {
    static let name = "Main"
    static let viewController = StoryboardReference<MainStoryboard, TagsModalViewController>(id: "TagsModalViewControllerID")
}

class DetailViewController: DetailViewControllerDraggable, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
//    var passedImage: UIImage!
    var passedScreenshotUUID: String?
    var passedScreenshotPosition: Int?
    var screenshotIDSet: [String?] = []
    var screenshotImageSet: [UIImage?] = []
    
    //MARK: Setup slideshow
    @IBOutlet weak var screenshotSlideshow: ImageSlideshow!
    var imageSource: [ImageSource] = []
    
    @IBOutlet weak var toolbarContainer: UIView!
    
    @IBOutlet weak var screenshotDetail: UIImageView!
    
    func getDocumentsDirectory() -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryURL
    }
    
    func populateData() {
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)
        for screenshot in screenshots {
            let screenshotURL = getDocumentsDirectory().appendingPathComponent(screenshot.screenshotFileName)
            let screenshotPath = screenshotURL.path
            screenshotIDSet.append(screenshot.screenshotID)
            let img = UIImage(contentsOfFile: screenshotPath)
            screenshotImageSet.append(img)
            imageSource.append(ImageSource(image: img!))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        screenshotDetail.contentMode = .scaleAspectFit
        
        self.navigationController?.isNavigationBarHidden = true
        self.modalPresentationCapturesStatusBarAppearance = true
        self.populateData()
        self.screenshotSlideshow.setImageInputs(imageSource)
        self.screenshotSlideshow.circular = false
        self.screenshotSlideshow.setCurrentPage(passedScreenshotPosition!, animated: false)
        self.screenshotSlideshow.pageIndicator = nil
        print("current page:", screenshotSlideshow.currentPage)
        self.screenshotSlideshow.currentPageChanged = { page in
            print("current page:", page)
            self.passedScreenshotPosition = page
            self.passedScreenshotUUID = self.screenshotIDSet[page]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    //MARK: Toggle UI on tap
    
    var visible: Bool = true

    override var prefersStatusBarHidden: Bool {
        return !visible
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    var originalToolBarPosition: CGPoint?
    
    @IBAction func hideUI() {
        originalToolBarPosition = self.toolbarContainer.center
        if visible == true {
//            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut, animations: {
//                self.toolbarContainer.isHidden = true
//            }, completion: nil)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.visible = false
                self.view.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.toolbarContainer.frame.origin = CGPoint(x: 0, y: self.view.layer.bounds.height )
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.visible = true
                self.view.layer.backgroundColor = #colorLiteral(red: 0.9497935176, green: 0.9562532306, blue: 0.9594267011, alpha: 1)
                self.toolbarContainer.frame.origin = CGPoint(x: 0, y: self.view.layer.bounds.height - self.toolbarContainer.layer.bounds.height)
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: nil)
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut, animations: {
                self.toolbarContainer.isHidden = false
            }, completion: nil)
        }
    }
    
    //MARK: Bottom toolbar
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var bottomToolbar: UIView!
    @IBOutlet weak var shareButton: NSLayoutConstraint!
    @IBOutlet weak var addTags: UIButton!

    @IBAction func openTags(_ sender: Any) {
        let viewController = MainStoryboard.viewController.instantiate()
        let transitionDelegate = TagsModalTransitioningDelegate()
        viewController.transitioningDelegate = transitionDelegate
        viewController.modalPresentationStyle = .custom
        viewController.passedScreenshotUUID = passedScreenshotUUID
        UIView.animate(withDuration: 0.3, animations: {
            self.present(viewController, animated: true, completion: nil)
        })
    }
    
    @IBAction func shareScreenshot(_ sender: Any) {
        let imageToShare = screenshotImageSet[passedScreenshotPosition!] as Any
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
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
            self.screenshotIDSet.remove(at: self.screenshotSlideshow.currentPage)
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

