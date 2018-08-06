//
//  MainViewController.swift
//  Collect
//
//  Created by Adam Amran on 05/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import UIKit
import RealmSwift

class Screenshot: Object {
    @objc dynamic var screenshotID = ""
    let tags = List<Tag>()
}

class Tag: Object {
    @objc dynamic var tagName = ""
}

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
    
    @IBAction func addScreenshotButton(_ sender: Any) {
        let screenshotPicker = UIImagePickerController()
        screenshotPicker.allowsEditing = false
        screenshotPicker.sourceType = .savedPhotosAlbum
        screenshotPicker.delegate = self
        present(screenshotPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard (info[UIImagePickerControllerEditedImage] as? UIImage) != nil else {
            print("No image found")
            return
        }
    }

    @IBOutlet weak var screenshotCollectionHome: UICollectionView!
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenshotCell", for: indexPath)
        return cell
    }
    
    
}


