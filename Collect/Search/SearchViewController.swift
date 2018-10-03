//
//  SearchViewController.swift
//  Collect
//
//  Created by Adam Amran on 10/09/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

private let reuseIdentifier = "tagCellIdentifier"

class SearchViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTagsCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchButtonBottomConstraint: NSLayoutConstraint!
    
    var selectedScreenshotsIDs: [String] = []
    
    var isSearchActive:Bool = false
    
    let realm = try! Realm()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tagsFlowLayout: TagsFlowLayout!
    var sizingCell: TagCell?
    
    override func viewDidLoad() {
        searchBar.becomeFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
        self.navigationItem.titleView = self.searchBar
        searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.becomeFirstResponder()
        self.searchButton.layer.cornerRadius = 25
        
        let tagCellNib = UINib(nibName: "TagCell", bundle: nil)
//        self.navigationController?.isNavigationBarHidden = true
        self.searchTagsCollectionView.register(tagCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.searchTagsCollectionView.delegate = self
        self.searchTagsCollectionView.dataSource = self
        self.searchTagsCollectionView.allowsMultipleSelection = true
        self.sizingCell = (tagCellNib.instantiate(withOwner: nil, options: nil)as NSArray).firstObject as! TagCell?
        
        self.searchButton.isEnabled = false
        if self.searchButton.isEnabled == false {
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
        self.searchButton.setTitle("No results", for: .disabled)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            self.searchButtonBottomConstraint.constant = isKeyboardShowing ? -(keyboardSize?.height)! : 0
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.searchBar.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.searchButton.frame.origin.y != UIScreen.main.bounds.height - self.searchButton.frame.height {
                self.searchButton.frame.origin.y = self.searchButton.frame.origin.y - keyboardSize.height
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        return print("hic sunt leones")
    }
    
    func resultsCount() -> Int {
        let count = self.selectedScreenshotsIDs.count
        return count
    }
    
    func setupSearchButton() {
        if self.selectedScreenshotsIDs.count == 0 {
            self.searchButton.setTitle("No results", for: .disabled)
            self.searchButton.isEnabled = false
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        } else {
            self.searchButton.setTitle("Show \(self.resultsCount()) results", for: .normal)
            self.searchButton.isEnabled = true
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0, green: 0.4, blue: 0.8274509804, alpha: 1)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.dismiss(animated: true, completion: nil)
        searchBar.becomeFirstResponder()
    }
    
    func tagsCount() -> Int {
        let tags = realm.objects(Tag.self)
        let tagsCount = tags.count
        return tagsCount
    }
    
    func configureCell(_ cell: TagCell, forIndexPath indexPath: IndexPath) {
        //        if ((indexPath.item) < self.usedTags().count) {
        //            let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true).filter("ANY linkedScreenshots.tags IN %@", self.usedTags() )
        //            let tagInfo = tags[indexPath.item]
        //            cell.isSelected = true
        //            tagsModalCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        //            cell.tagCellLabel.text = tagInfo.tagName
        //        } else  {
        //            let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true).filter("NONE linkedScreenshots.tags IN %@", self.usedTags() )
        //            let tagInfo = tags[indexPath.item]
        //            cell.isSelected = false
        //            tagsModalCollectionView.deselectItem(at: indexPath, animated: false)
        //            cell.tagCellLabel.text = tagInfo.tagName
        //        }
        let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
        let tagInfo = tags[indexPath.row]
        cell.tagCellLabel.text = tagInfo.tagName
    }
    
    func widthOfLabel(text:String, font:UIFont) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: CGFloat.greatestFiniteMagnitude))
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.width
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.height = 37
        let cellSize = self.sizingCell?.systemLayoutSizeFitting(fittingSize)
        return cellSize!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagCell = searchTagsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
//        } else {
//            let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true).filter("tags.tagName CONTAINS %@", searchText)
//        }
//        self.searchTagsCollectionView.reloadData()
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTag = realm.objects(Tag.self)[indexPath.row]
        let screenshots = realm.objects(Screenshot.self).filter("ANY tags == %@", selectedTag)
        for screenshot in screenshots {
            self.selectedScreenshotsIDs.append(screenshot.screenshotID)
        }
        self.setupSearchButton()
        print(self.selectedScreenshotsIDs.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedTag = realm.objects(Tag.self)[indexPath.row]
        let screenshots = realm.objects(Screenshot.self).filter("ANY tags == %@", selectedTag)
        for screenshot in screenshots {
            self.selectedScreenshotsIDs.removeAll { $0 == "\(screenshot.screenshotID)"}
        }
        self.setupSearchButton()
        print(self.selectedScreenshotsIDs.count)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "SearchToResults", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToResults" {
            let toSearchResultsViewController = segue.destination as! SearchResultsViewController
            toSearchResultsViewController.passedScreenshotIDs = selectedScreenshotsIDs
        }
    }
    
}

