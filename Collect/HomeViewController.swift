//
//  MainViewController.swift
//  Collect
//
//  Created by Adam Amran on 05/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import BSImagePicker
import Photos

class HomeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        screenshotCollectionHome.delegate = self
        screenshotCollectionHome.dataSource = self
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIImagePicker to add screenshots
    @IBAction func addScreenshotButton(_ sender: Any) {
        let screenshotPicker = BSImagePickerViewController()
        bs_presentImagePickerController(screenshotPicker, animated: true,
            select: { (asset: PHAsset) -> Void in
            // User selected an asset.
            // Do something with it, start upload perhaps?
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an assets.
            // Do something, cancel upload?
        }, cancel: { (assets: [PHAsset]) -> Void in
            // User cancelled. And this where the assets currently selected.
        }, finish: { (assets: [PHAsset]) -> Void in
            // Need to rewrite this in a way that works with "assets"". Fetch the localIdentifier, store it somehow (on select already?) and then save on finish. Or save the PHAsset to document directory
            for asset in assets {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var image = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    image = result!
                })
                let imageData = UIImagePNGRepresentation(image) as Data?
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
            
            DispatchQueue.main.async{
                self.screenshotCollectionHome.reloadData()
            }
        }, completion: nil)
    }

    @IBOutlet weak var screenshotCollectionHome: UICollectionView!
    
    func getDocumentsDirectory() -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryURL
    }
    
    func screenshotFile(_ fileName: String) -> String {
        let screenshotURL = getDocumentsDirectory().appendingPathComponent(fileName)
        return screenshotURL.path
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = screenshotCollectionHome.dequeueReusableCell(withReuseIdentifier: "screenshotCell", for: indexPath)
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)[indexPath.row]
        let screenshotURL: URL = getDocumentsDirectory().appendingPathComponent(screenshots.screenshotFileName)
        print(screenshotURL)
        print(screenshots.screenshotFileName)
        return cell
    }
    
}


