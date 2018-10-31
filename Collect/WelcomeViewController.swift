//
//  WelcomeViewController.swift
//  Collect
//
//  Created by Adam Amran on 22/10/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift
import Photos
import BSImagePicker
import TLPhotoPicker

class WelcomeViewController: UIViewController, TLPhotosPickerViewControllerDelegate {
    
    var screenshotImage: UIImage!
    var screenshotUUID: String?
    var screenshotPosition: Int?
    var screenshotImageSet: [UIImage?] = []
    @IBOutlet weak var importButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.importButton.layer.cornerRadius = 25
        self.importButton.layer.shadowRadius = 25
        self.importButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.importButton.layer.shadowOpacity = 0.6
        self.importButton.layer.masksToBounds = false
    }
    
    //MARK: UIImagePicker to add screenshots
    @IBAction func addScreenshots(_sender: Any) {
        let pickerVC = TLPhotosPickerViewController()
        pickerVC.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.allowedLivePhotos = false
        configure.usedCameraButton = false
        
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        for asset in withPHAssets {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                image = result!
            })
            let imageData = image.pngData() as Data?
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uuid = UUID().uuidString
            let screenshot = Screenshot()
            let writePath = documentsDirectory.appendingPathComponent("\(uuid).png")
            try! imageData?.write(to: writePath as URL, options: [.atomic])
            screenshot.screenshotID = uuid
            screenshot.screenshotFileName = "\(uuid).png"
            let realm = try! Realm()
            try! realm.write {
                realm.add(screenshot)
            }
        }
    }
    
    func dismissComplete() {
        self.importDone()
    }
    
    
    func importDone() {
        UserDefaults.standard.set(true, forKey: "firstImport")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadCollection"), object: nil))
        //        self.performSegue(withIdentifier: "WelcomeToHome", sender: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.present(homeVC, animated: true, completion: nil)
    }
    
}
