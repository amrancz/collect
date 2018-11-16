//
//  DataModel.swift
//  Collect
//
//  Created by Adham Amran on 07/08/2018.
//  Copyright © 2018 Adham Amran. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Screenshot: Object {
    @objc dynamic var screenshotID = ""
    @objc dynamic var screenshotFileName = ""
    @objc dynamic var dateAdded = ""
    let tags = List<Tag>()
}

class Tag: Object {
    @objc dynamic var tagName = ""
    @objc dynamic var tagID = ""
    let linkedScreenshots = LinkingObjects(fromType: Screenshot.self, property: "tags")
    
    override class func primaryKey() -> String? {
        return "tagID"
    }
}
