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

class ManageTagsTableViewController: UITableViewController {
    
    @IBOutlet var tagsTableView: UITableView!
    
    func tagsCount() -> Int {
        let realm = try! Realm()
        let tags = realm.objects(Tag.self)
        let tagsCount = tags.count
        return tagsCount
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
        let realm = try! Realm()
        let tag = realm.objects(Tag.self).sorted(byKeyPath: "tagName", ascending: true)[indexPath.row]
        try! realm.write {
            realm.delete(tag)
            realm.refresh()
        }
        print ("Updated tagCount is \(tagsCount())")
        self.tableView.reloadData()
        // TO FIX: Deleting row with animation throws NSInternalInconsistencyException – invalid number of rows
        // tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
