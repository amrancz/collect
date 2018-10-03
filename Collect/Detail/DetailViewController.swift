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

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    var passedImage: UIImage!
    var passedScreenshotUUID: String?
    
    var tagsPreviewViewController: TagsPreviewViewController?
    
    @IBOutlet weak var screenshotDetail: UIImageView!
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        self.navigationController?.isNavigationBarHidden = true
        screenshotDetail.image = passedImage
        screenshotDetail.contentMode = .scaleAspectFit
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToTagsPreview" {
            tagsPreviewViewController = segue.destination as? TagsPreviewViewController
            tagsPreviewViewController?.passedScreenshotUUID = passedScreenshotUUID
        }
    }


}

