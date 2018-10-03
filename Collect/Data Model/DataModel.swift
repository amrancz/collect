//
//  DataModel.swift
//  Collect
//
//  Created by Adam Amran on 07/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Screenshot: Object {
    @objc dynamic var screenshotID = ""
    @objc dynamic var screenshotFileName = ""
    let tags = List<Tag>()
}

class Tag: Object {
    @objc dynamic var tagName = ""
    @objc dynamic var tagID = ""
    let linkedScreenshots = LinkingObjects(fromType: Screenshot.self, property: "tags")
    
    override class func primaryKey() -> String? {
        return "tagName"
    }
}
