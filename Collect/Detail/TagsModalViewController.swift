//
//  TagsModalViewController.swift
//  Collect
//
//  Created by Adam Amran on 25/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

private let reuseIdentifier = "tagCellIdentifier"

class TagsModalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let realm = try! Realm()
    var passedScreenshotUUID: String?
    lazy var selectedScreenshot = realm.objects(Screenshot.self).filter("screenshotID == %@", passedScreenshotUUID!)
    
    
    @IBOutlet var tagsModalCollectionView: UICollectionView!
    @IBOutlet weak var tagsFlowLayout: TagsFlowLayout!
    var sizingCell: TagCell?
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tagCellNib = UINib(nibName: "TagCell", bundle: nil)
        self.tagsModalCollectionView.register(tagCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.tagsModalCollectionView.delegate = self
        self.tagsModalCollectionView.dataSource = self
        self.tagsModalCollectionView.allowsMultipleSelection = true
        self.sizingCell = (tagCellNib.instantiate(withOwner: nil, options: nil)as NSArray).firstObject as! TagCell?
        print(passedScreenshotUUID as Any)
        print(usedTags().count)
        print(unusedTags())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func usedTags() -> List<Tag> {
        let screenshot = realm.objects(Screenshot.self).filter("screenshotID = %@", self.passedScreenshotUUID!).first
        let usedTags = screenshot?.tags
        return usedTags!
    }
    
    func unusedTags() -> Results<Tag> {
        let unusedTags = realm.objects(Tag.self).filter("NONE linkedScreenshots.tags IN %@", self.usedTags() )
        return unusedTags
    }
    
    func tagsCount() -> Int {
        let tags = realm.objects(Tag.self)
        let tagsCount = tags.count
        return tagsCount
    }
    
//    func widthOfLabel(text:String, font:UIFont) -> CGFloat {
//        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: CGFloat.greatestFiniteMagnitude))
//        label.font = font
//        label.text = text
//        label.sizeToFit()
//        return label.frame.width
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return usedTags().count
        } else if section == 1 {
            return unusedTags().count
        }
        return 0
    }
    
    func configureCell(_ cell: TagCell, forIndexPath indexPath: IndexPath) {
        if indexPath.section == 0 {
            let tags = usedTags().sorted(byKeyPath: "tagName", ascending: true)
            let tagInfo = tags[indexPath.row]
            cell.isSelected = true
            tagsModalCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.tagCellLabel.text = tagInfo.tagName
        } else {
            let tags = unusedTags().sorted(byKeyPath: "tagName", ascending: true)
            let tagInfo = tags[indexPath.row]
            cell.isSelected = false
            tagsModalCollectionView.deselectItem(at: indexPath, animated: false)
            cell.tagCellLabel.text = tagInfo.tagName
        }
//        let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
//        let tagInfo = tags[indexPath.row]
//        cell.tagCellLabel.text = tagInfo.tagName
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.height = 37
        let cellSize = self.sizingCell?.systemLayoutSizeFitting(fittingSize)
        return cellSize!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagCell = tagsModalCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: TagCell = tagsModalCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        if indexPath.section == 0 {
            let selectedTag = usedTags().sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
            if let screenshotToSaveTo = self.selectedScreenshot.first {
                try! realm.write {
                    screenshotToSaveTo.tags.append(selectedTag)
                }
            }
            cell.isSelected = true
            tagsModalCollectionView.reloadData()

        } else {
            let selectedTag = unusedTags().sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
            if let screenshotToSaveTo = self.selectedScreenshot.first {
                try! realm.write {
                    screenshotToSaveTo.tags.append(selectedTag)
                }
            }
            cell.isSelected = true
            tagsModalCollectionView.reloadData()

        }
//        let selectedTag = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
//        if let screenshotToSaveTo = self.selectedScreenshot.first {
//            try! realm.write {
//                screenshotToSaveTo.tags.append(selectedTag)
//            }
//        }
//        cell.isSelected = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell: TagCell = tagsModalCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        if indexPath.section == 0 {
            let selectedTag = usedTags().sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
            let screenshot = selectedScreenshot.first
            try! realm.write {
                if let index = screenshot?.tags.index(of: selectedTag) {
                    screenshot?.tags.remove(at: index)
                }
            }
            cell.isSelected = false
            tagsModalCollectionView.reloadData()

        } else {
            let selectedTag = unusedTags().sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
            let screenshot = selectedScreenshot.first
            try! realm.write {
                if let index = screenshot?.tags.index(of: selectedTag) {
                    screenshot?.tags.remove(at: index)
                }
            }
            cell.isSelected = false
            tagsModalCollectionView.reloadData()

        }
//        let selectedTag = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
//        let screenshot = selectedScreenshot.first
//        try! realm.write {
//            if let index = screenshot?.tags.index(of: selectedTag) {
//                screenshot?.tags.remove(at: index)
//            }
//        }
//        cell.isSelected = false
    }
    @IBAction func addTag(_ sender: Any) {
        let addTagAlertController = UIAlertController(title: "Add Tag", message: "Name this new tag", preferredStyle: .alert)
        addTagAlertController.addTextField { (_ textField: UITextField) -> Void in
            textField.placeholder = "Tag name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
        }
        let addTagAction = UIAlertAction(title: "Add tag", style: .default){ (action:UIAlertAction!) in
            let realm = try! Realm()
            let uuid = UUID().uuidString
            let tag = Tag()
            tag.tagID = uuid
            let textField = addTagAlertController.textFields?.first
            tag.tagName = (textField?.text!)!
            let screenshotToSaveTo = self.selectedScreenshot.first
            try! realm.write {
                realm.add(tag, update: true)
                print (tag.tagName)
                screenshotToSaveTo?.tags.append(tag)
            }
            self.tagsModalCollectionView.reloadData()
        }
        addTagAlertController.addAction(cancelAction)
        addTagAlertController.addAction(addTagAction)
        self.present(addTagAlertController, animated: true, completion: nil)
    }
    
}

