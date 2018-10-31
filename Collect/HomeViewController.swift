//
//  MainViewController.swift
//  Collect
//
//  Created by Adam Amran on 05/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import BSImagePicker
import Photos
import TBEmptyDataSet
import TLPhotoPicker

class HomeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, TLPhotosPickerViewControllerDelegate {
    
    var screenshotImage: UIImage!
    var screenshotUUID: String?
    var screenshotPosition: Int?
    var screenshotImageSet: [UIImage?] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        screenshotCollectionHome.delegate = self
        screenshotCollectionHome.dataSource = self
        screenshotCollectionHome.emptyDataSetDelegate = self
        screenshotCollectionHome.emptyDataSetDataSource = self
        self.searchButton.layer.cornerRadius = 25
        self.searchButton.layer.shadowRadius = 10
        self.searchButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.searchButton.layer.shadowOpacity = 0.6
        self.searchButton.layer.masksToBounds = false

        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCollection(_:)), name: Notification.Name(rawValue: "reloadCollection"), object: nil)
        print(Realm.Configuration.defaultConfiguration.fileURL!)

    }
    
    @objc func refreshCollection(_ notification:Notification) {
        self.screenshotCollectionHome.reloadData()
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        DispatchQueue.main.async{
            self.screenshotCollectionHome.reloadData()
        }
    }
    
    
    @IBOutlet weak var searchButton: UIButton!
    
    //MARK: Configure collectionView
    
    @IBOutlet weak var screenshotCollectionHome: UICollectionView!
    
    func getDocumentsDirectory() -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryURL
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt cellForRowAtIndexPath: IndexPath) -> UICollectionViewCell {
        let cell = screenshotCollectionHome.dequeueReusableCell(withReuseIdentifier: "screenshotCell", for: cellForRowAtIndexPath) as! ScreenshotCell
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)[cellForRowAtIndexPath.row]
        let screenshotURL = getDocumentsDirectory().appendingPathComponent(screenshots.screenshotFileName)
        let screenshotPath = screenshotURL.path
        if let imageData = UIImage(contentsOfFile: screenshotPath) {
            cell.imageView.contentMode = .scaleAspectFit
            cell.imageView.image = imageData
            screenshotImageSet.append(imageData)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = screenshotCollectionHome.cellForItem(at: indexPath) as! ScreenshotCell
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)[indexPath.row]
        screenshotImage = cell.imageView.image
        screenshotUUID = screenshots.screenshotID
        self.screenshotPosition = indexPath.item
        performSegue(withIdentifier: "HomeToDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToDetail" {
            let toDetailNavigationController = segue.destination as! UINavigationController
            let toDetailViewController = toDetailNavigationController.viewControllers.first as! DetailViewController
            toDetailViewController.passedImage = screenshotImage
            toDetailViewController.passedScreenshotUUID = screenshotUUID
            toDetailViewController.passedScreenshotImageSet = screenshotImageSet
            toDetailViewController.passedScreenshotPosition = screenshotPosition
        }
    }
    
}

extension HomeViewController: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    
    //MARK: Configure empty state
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        if screenshotCollectionHome.numberOfItems(inSection: 0) == 0 {
            return true
        } else {
            return false
        }
    }
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "mainEmptyImage")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any]?
        attributes = [.font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.heavy),
                      .foregroundColor: UIColor.black]
        return NSAttributedString(string: "Your collection is empty", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any]?
        attributes = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular),
                      .foregroundColor: UIColor.gray]
        return NSAttributedString(string: "Go ahead and import some screenshots.", attributes: attributes)
    }
    
    func verticalSpacesForEmptyDataSet(in scrollView: UIScrollView) -> [CGFloat] {
        return [30,10]
    }

}

