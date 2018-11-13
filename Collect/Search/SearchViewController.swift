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

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTagsCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchButtonContainer: UIView!
    
    var selectedTags: [String] = []
    
    lazy var realm = try! Realm()

    var selectedScreenshotsIDs: [String] = []
    var screenshotsToPass: Results<Screenshot>!

    var filteredTags: Results<Tag>!
    
    func allTags() -> Results<Tag> {
        let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
        return tags
    }
    
    func getDocumentsDirectory() -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryURL
    }
    
    func getScreenshots() -> Results<Screenshot> {
        let screenshots = realm.objects(Screenshot.self).filter("screenshotID IN %@", selectedScreenshotsIDs)
        return screenshots
    }
    
    var isSearchActive:Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tagsFlowLayout: TagsFlowLayout!
    var sizingCell: TagCell?
    
    override func viewDidLoad() {
        self.searchBar.resignFirstResponder()
        self.keepCancelButtonActive()
        self.navigationItem.titleView = self.searchBar
        self.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.becomeFirstResponder()
        self.searchBar.returnKeyType = .done
        filteredTags = allTags()
        
        let tagCellNib = UINib(nibName: "TagCell", bundle: nil)
        self.searchTagsCollectionView.register(tagCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        self.searchTagsCollectionView.delegate = self
        self.searchTagsCollectionView.dataSource = self
        self.searchTagsCollectionView.allowsMultipleSelection = true
        self.sizingCell = (tagCellNib.instantiate(withOwner: nil, options: nil)as NSArray).firstObject as! TagCell?
        
        self.searchButton.isEnabled = false
        if self.searchButton.isEnabled == false {
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            self.searchButtonContainer.layer.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)

        }
        self.searchButton.setTitle("No results", for: .disabled)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.keepCancelButtonActive()
        self.selectedTags.removeAll()
    }

    
    func resultsCount() -> Int {
        let array = self.selectedScreenshotsIDs
        let count = NSSet(array: array).count
        return count
    }
    
    func setupSearchButton() {
        if resultsCount() == 0 {
            self.searchButton.setTitle("No results", for: .disabled)
            self.searchButton.isEnabled = false
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            self.searchButtonContainer.layer.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        } else if resultsCount() == 1 {
            self.searchButton.setTitle("Show \(self.resultsCount()) result", for: .normal)
            self.searchButton.isEnabled = true
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0, green: 0.4, blue: 0.8274509804, alpha: 1)
            self.searchButtonContainer.layer.backgroundColor = #colorLiteral(red: 0, green: 0.4, blue: 0.8274509804, alpha: 1)
        }  else {
            self.searchButton.setTitle("Show \(self.resultsCount()) results", for: .normal)
            self.searchButton.isEnabled = true
            self.searchButton.layer.backgroundColor = #colorLiteral(red: 0, green: 0.4, blue: 0.8274509804, alpha: 1)
            self.searchButtonContainer.layer.backgroundColor = #colorLiteral(red: 0, green: 0.4, blue: 0.8274509804, alpha: 1)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.dismiss(animated: true, completion: nil)
        searchBar.resignFirstResponder()
        self.keepCancelButtonActive()
    }

    func keepCancelButtonActive() {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    func configureCell(_ cell: TagCell, forIndexPath indexPath: IndexPath) {
        let tagInfo = filteredTags[indexPath.row]
        cell.tagCellLabel.text = tagInfo.tagName
        if self.selectedTags.contains(tagInfo.tagName) {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
    }
    
    func widthOfLabel(text:String, font:UIFont) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = text
        label.sizeToFit()
        return label.frame.width+32
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        self.configureCell(self.sizingCell!, forIndexPath: indexPath)
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = widthOfLabel(text: (self.sizingCell?.tagCellLabel.text)!, font: UIFont.systemFont(ofSize: 17))
        fittingSize.height = 37
        let cellSize = CGSize.init(width: fittingSize.width, height: fittingSize.height)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagCell = searchTagsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTag = filteredTags[indexPath.item]
//        let selectedTag = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.item]
        let screenshots = realm.objects(Screenshot.self).filter("ANY tags == %@", selectedTag)
        for screenshot in screenshots {
            self.selectedScreenshotsIDs.append(screenshot.screenshotID)
            self.selectedTags.append(selectedTag.tagName)
        }
        self.setupSearchButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedTag = filteredTags[indexPath.item]
        let screenshots = realm.objects(Screenshot.self).filter("ANY tags == %@", selectedTag)
        for screenshot in screenshots {
            if let index = self.selectedScreenshotsIDs.index(where: { $0 == "\(screenshot.screenshotID)"}) {
                self.selectedScreenshotsIDs.remove(at: index)
            }
            if let tagIndex = self.selectedTags.index(where: { $0 == "\(selectedTag.tagName)"}) {
                self.selectedTags.remove(at: tagIndex)
            }
        }
        self.setupSearchButton()
    }
    
    //MARK: Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            let searchedTags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
            filteredTags = searchedTags
            self.selectedScreenshotsIDs.removeAll()
            self.setupSearchButton()
        } else {
            let searchedTags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true).filter("tagName contains[c] %@", searchText)
            filteredTags = searchedTags
        }
        self.searchTagsCollectionView.reloadData()
    }
    
    //MARK: Perform search
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        screenshotsToPass = self.getScreenshots()
        performSegue(withIdentifier: "SearchToResults", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToResults" {
            let toSearchResultsViewController = segue.destination as! SearchResultsViewController
            toSearchResultsViewController.passedScreenshotIDs = selectedScreenshotsIDs
            toSearchResultsViewController.screenshotsToPass = screenshotsToPass
        }
    }
}

