//
//  SearchResultsViewController.swift
//  Collect
//
//  Created by Adam Amran on 03/10/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

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


class SearchResultsViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var screenshotImage: UIImage!
    var screenshotUUID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        screenshotCollectionHome.delegate = self
        screenshotCollectionHome.dataSource = self
        
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
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = screenshotCollectionHome.cellForItem(at: indexPath) as! ScreenshotCell
        let realm = try! Realm()
        let screenshots = realm.objects(Screenshot.self)[indexPath.row]
        screenshotImage = cell.imageView.image
        screenshotUUID = screenshots.screenshotID
        performSegue(withIdentifier: "HomeToDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToDetail" {
            let toDetailViewController = segue.destination as! DetailViewController
            toDetailViewController.passedImage = screenshotImage
            toDetailViewController.passedScreenshotUUID = screenshotUUID
        }
    }
    
}

