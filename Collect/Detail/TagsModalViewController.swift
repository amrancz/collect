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
    var selectedScreenshot: Results<Screenshot>?
    
    var tagNames: [String] = []
    
    func allTags() {
        let tags = realm.objects(Tag.self)
        for tag in tags {
            self.tagNames.append(tag.tagName.lowercased())
        }
    }
    
    @IBOutlet var tagsModalCollectionView: UICollectionView!
    @IBOutlet weak var tagsFlowLayout: TagsFlowLayout!
    var sizingCell: TagCell?
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTags()
        selectedScreenshot = realm.objects(Screenshot.self).filter("screenshotID == %@", passedScreenshotUUID!)
        let tagCellNib = UINib(nibName: "TagCell", bundle: nil)
        self.tagsModalCollectionView.register(tagCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.tagsModalCollectionView.delegate = self
        self.tagsModalCollectionView.dataSource = self
        self.tagsModalCollectionView.allowsMultipleSelection = true
        self.sizingCell = (tagCellNib.instantiate(withOwner: nil, options: nil)as NSArray).firstObject as! TagCell?
    }
    
    func usedTags() -> List<Tag> {
        let screenshot = realm.objects(Screenshot.self).filter("screenshotID = %@", self.passedScreenshotUUID!).first
        let usedTags = screenshot?.tags
        return usedTags!
    }
    
    func unusedTags() -> Results<Tag> {
//        let allTags = realm.objects(Tag.self)//.filter("NONE linkedScreenshots.tags IN %@", self.usedTags() )
//        let converted = allTags.reduce(List<Tag>()) { (list, tag) -> List<Tag> in
//            list.append(tag)
//            return list
//        }
        let unused = realm.objects(Tag.self).filter("NONE in %@", self.usedTags())
//        let listOfUnused = converted.filter("NONE in %@", self.usedTags())
        return unused
    }
    
    func tagsCount() -> Int {
        let tags = realm.objects(Tag.self)
        let tagsCount = tags.count
        return tagsCount
    }
    
    func widthOfLabel(text:String) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = text
        label.sizeToFit()
        return label.frame.width+32
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            print(usedTags().count)
            return usedTags().count
        } else if section == 1 {
            print(unusedTags().count)
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = widthOfLabel(text: (self.sizingCell?.tagCellLabel.text)!)
        fittingSize.height = 37
        let cellSize = CGSize.init(width: fittingSize.width, height: fittingSize.height)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagCell = tagsModalCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: TagCell = tagsModalCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        let selectedTag = unusedTags().sorted(byKeyPath: "tagName", ascending: true)[indexPath.item]
        if let screenshotToSaveTo = self.selectedScreenshot!.first {
            try! realm.write {
                screenshotToSaveTo.tags.append(selectedTag)
            }
        }
        cell.isSelected = true
        tagsModalCollectionView.reloadData()

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell: TagCell = tagsModalCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        let selectedTag = usedTags().sorted(byKeyPath: "tagName", ascending: true)[indexPath.item]
        let screenshot = selectedScreenshot!.first
        try! realm.write {
            if let index = screenshot?.tags.index(of: selectedTag) {
                screenshot?.tags.remove(at: index)
            }
        }
        cell.isSelected = false
        tagsModalCollectionView.reloadData()
    }
    
    @IBAction func addTag(_ sender: Any) {
        let addTagAlertController = UIAlertController(title: "Add Tag", message: "Name this new tag", preferredStyle: .alert)
        addTagAlertController.addTextField { (_ textField: UITextField) -> Void in
            textField.placeholder = "Tag name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
        }
        let addTagAction = UIAlertAction(title: "Add tag", style: .default){ (action:UIAlertAction!) in
            let uuid = UUID().uuidString
            let tag = Tag()
            tag.tagID = uuid
            let textField = addTagAlertController.textFields?.first
            tag.tagName = (textField?.text!)!
            let screenshotToSaveTo = self.selectedScreenshot!.first
            if self.tagNames.contains(where: {$0.caseInsensitiveCompare(tag.tagName) == .orderedSame}) {
                let tagToSave = self.realm.objects(Tag.self).filter("tagName =[c] %@", tag.tagName).first
                try! self.realm.write {
                    screenshotToSaveTo!.tags.append(tagToSave!)
                }
                self.tagNames.append(tag.tagName)
            } else {
                try! self.realm.write {
                    self.realm.add(tag, update: true)
                    screenshotToSaveTo?.tags.append(tag)
                }
                self.tagNames.append(tag.tagName)
                print ("tag already exists")
            }
            self.tagsModalCollectionView.reloadData()
        }
        addTagAlertController.addAction(cancelAction)
        addTagAlertController.addAction(addTagAction)
        self.present(addTagAlertController, animated: true, completion: nil)
    }
    
}

