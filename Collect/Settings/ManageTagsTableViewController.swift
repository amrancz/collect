//
//  ManageTagsTableViewController.swift
//  Collect
//
//  Created by Adham Amran on 17/08/2018.
//  Copyright © 2018 Adham Amran. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm
import TBEmptyDataSet

class ManageTagsTableViewController: UITableViewController {
    
    @IBOutlet var tagsTableView: UITableView!
    var tagNames: [String] = []
    lazy var realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        allTags()
        styleTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tagNames.removeAll()
    }
    
    func tagsCount() -> Int {
        let tags = realm.objects(Tag.self)
        let tagsCount = tags.count
        return tagsCount
    }
    
    func allTags() {
        let tags = realm.objects(Tag.self)
        for tag in tags {
            self.tagNames.append(tag.tagName)
        }
    }
    
    func styleTableView() {
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            self.tableView.separatorStyle = .none
            self.tableView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9490196078, alpha: 1)
            self.editButton.isEnabled = false
        } else {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.editButton.isEnabled = true
        }
    }
        
    @IBAction func addTag(_ sender: Any) {
        let addTagAlertController = UIAlertController(title: "Add Tag", message: "", preferredStyle: .alert)
        addTagAlertController.addTextField { (_ textField: UITextField) -> Void in
            textField.placeholder = "E.g. 'Form'"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
        }
        let addTagAction = UIAlertAction(title: "Add Tag", style: .default){ (action:UIAlertAction!) in
            let uuid = UUID().uuidString
            let tag = Tag()
            tag.tagID = uuid
            let textField = addTagAlertController.textFields?.first
            tag.tagName = (textField?.text!)!
            if self.tagNames.contains(where: {$0.caseInsensitiveCompare(tag.tagName) == .orderedSame}) {
                self.tagAlreadyExsits()
            } else {
                try! self.realm.write {
                    self.realm.add(tag, update: true)
                }
                self.tagNames.append(tag.tagName)
            }
            self.tableView.reloadData()
        }
        addTagAlertController.addAction(cancelAction)
        addTagAlertController.addAction(addTagAction)
        self.present(addTagAlertController, animated: true, completion: nil)
    }
    
    func tagAlreadyExsits() {
        let tagAlreadyExsitsController = UIAlertController(title: "This tag already exists", message: "Try to add a different one", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
        }
        tagAlreadyExsitsController.addAction(dismissAction)
        self.present(tagAlreadyExsitsController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell: UITableViewCell? = tagsTableView.dequeueReusableCell(withIdentifier: "tagTableCell", for: indexPath)
//        if (cell == nil) {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "tagTableCell")
        let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
        let tagInfo = tags[indexPath.row]
        cell.textLabel?.text = tagInfo.tagName
        cell.detailTextLabel?.text = "\(tagInfo.linkedScreenshots.count)×"
        styleTableView()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
        let editTagAlertController = UIAlertController(title: "Edit Tag", message: "", preferredStyle: .alert)
        editTagAlertController.addTextField { (_ textField: UITextField) -> Void in
            textField.text = tag.tagName
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) in
            let textField = editTagAlertController.textFields?.first
            try! self.realm.write {
                tag.tagName = (textField?.text)!
            }
            self.tableView.reloadData()
        }
        editTagAlertController.addAction(cancelAction)
        editTagAlertController.addAction(saveAction)
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(editTagAlertController, animated: true, completion: nil)

    }
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editTableView(_ sender: Any) {
        if (self.tableView.isEditing == false) {
            self.tableView.setEditing(true, animated: true)
            self.editButton.title = "Done"
        } else {
            self.tableView.setEditing(false, animated: true)
            self.editButton.title = "Edit"
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.beginUpdates()
        let tag = self.realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
        try! self.realm.write {
            self.realm.delete(tag)
            self.realm.refresh()
        }
        tagNames.removeAll()
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.endUpdates()
        styleTableView()
        allTags()
    }
}

extension ManageTagsTableViewController: TBEmptyDataSetDataSource, TBEmptyDataSetDelegate {
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        if tableView.numberOfRows(inSection: 0) == 0 {
            return true
        } else {
            return false
        }
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any]?
        attributes = [.font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.heavy),
                      .foregroundColor: UIColor.black]
        return NSAttributedString(string: "You have no tags", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        var attributes: [NSAttributedString.Key: Any]?
        attributes = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular),
                      .foregroundColor: UIColor.gray]
        return NSAttributedString(string: "Go ahead and add some.", attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        return -40
    }
}
