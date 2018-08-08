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

class HomeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        screenshotCollectionHome.delegate = self
        screenshotCollectionHome.dataSource = self
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
        bs_presentImagePickerController(screenshotPicker, animated: true, select: { (asset: PHAsset) -> Void in
            // User selected an asset.
            // Do something with it, start upload perhaps?
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an assets.
            // Do something, cancel upload?
        }, cancel: { (assets: [PHAsset]) -> Void in
            // User cancelled. And this where the assets currently selected.
        }, finish: { (assets: [PHAsset]) -> Void in
            let image = UIImage()
            let fileManager = FileManager.default
            let imageData = UIImagePNGRepresentation(image) as Data?
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uuid = UUID().uuidString
            print (uuid)
            print (documentsDirectory)
            
            let writePath = documentsDirectory.appendingPathComponent("\(uuid).png")
            print (writePath)
            
            try! imageData?.write(to: writePath as URL, options: [.atomicWrite])
            
            let screenshot = Screenshot()
            screenshot.screenshotID = uuid
            screenshot.screenshotFileName = "\(uuid).png"
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(screenshot)
                print ("Screenshot added to Realm!")
                print (screenshot)
            }
        }, completion: nil)
    }

    @IBOutlet weak var screenshotCollectionHome: UICollectionView!
    
}

private var cellCount = 2

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenshotCell", for: indexPath)
        return cell
    }
    
    func emptyCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (cellCount == 0) {
            self.screenshotCollectionHome.setEmptyView("No screenshots")
        } else {
            self.screenshotCollectionHome.restore()
        }
        
        return cellCount
    }
    
}

extension UICollectionView {
    func setEmptyView(_ emptyMessage: String) {
        let messageCopy = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageCopy.text = emptyMessage
        messageCopy.textColor = .black
        messageCopy.textAlignment = .center;
        messageCopy.font = UIFont(name: "Helvetica", size: 25)
        messageCopy.sizeToFit()
        
        self.backgroundView = messageCopy
    }
    
    func restore() {
        self.backgroundView = nil
    }
}


