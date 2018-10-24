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

class WelcomeViewController: UIViewController {
    
    var screenshotImage: UIImage!
    var screenshotUUID: String?
    var screenshotPosition: Int?
    var screenshotImageSet: [UIImage?] = []
    
    //MARK: UIImagePicker to add screenshots
    @IBAction func addScreenshotButton(_ sender: Any) {
        let screenshotPicker = BSImagePickerViewController()
        bs_presentImagePickerController(screenshotPicker, animated: true,
                                        select: { (asset: PHAsset) -> Void in
        }, deselect: { (asset: PHAsset) -> Void in
        }, cancel: { (assets: [PHAsset]) -> Void in
        }, finish: { (assets: [PHAsset]) -> Void in
            for asset in assets {
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
        }, completion: nil)
    }
}
