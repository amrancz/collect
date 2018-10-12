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
    
    var tagsPreviewViewController: TagsPreviewViewController?
    @IBOutlet weak var toolbarContainer: UIView!
    
    @IBOutlet weak var screenshotDetail: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    var visible: Bool = true
    
    @IBAction func hideUI() {
        visible = !visible
        if visible == true {
            UIView.animate(withDuration: 0.2) {
                self.view.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.toolbarContainer.isHidden = true
                self.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.view.layer.backgroundColor = #colorLiteral(red: 0.9497935176, green: 0.9562532306, blue: 0.9594267011, alpha: 1)
                self.toolbarContainer.isHidden = false
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    override var prefersStatusBarHidden: Bool {
        return !visible
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToTagsPreview" {
            tagsPreviewViewController = segue.destination as? TagsPreviewViewController
            tagsPreviewViewController?.passedScreenshotUUID = passedScreenshotUUID
        }
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
}

