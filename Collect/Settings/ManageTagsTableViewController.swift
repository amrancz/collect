//
//  ManageTagsTableViewController.swift
//  Collect
//
//  Created by Adam Amran on 17/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm
import TBEmptyDataSet

class ManageTagsTableViewController: UITableViewController {
    
    @IBOutlet var tagsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        styleTableView()
    }
    
    func tagsCount() -> Int {
        let realm = try! Realm()
        let tags = realm.objects(Tag.self)
        let tagsCount = tags.count
        return tagsCount
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
            try! realm.write {
                realm.add(tag, update: true)
                print (tag.tagName)
            }
            self.tableView.reloadData()
        }
        addTagAlertController.addAction(cancelAction)
        addTagAlertController.addAction(addTagAction)
        self.present(addTagAlertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("Current tagCount is \(tagsCount())")
        return tagsCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tagsTableView.dequeueReusableCell(withIdentifier: "tagTableCell", for: indexPath)
        let realm = try! Realm()
        let tags = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)
        let tagInfo = tags[indexPath.row]
        cell.textLabel?.text = tagInfo.tagName
        styleTableView()
        return cell
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
        let realm = try! Realm()
        let tag = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
        try! realm.write {
            realm.delete(tag)
            realm.refresh()
        }
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.endUpdates()
        styleTableView()
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
