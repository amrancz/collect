//
//  StoryboardReference.swift
//  Collect
//
//  Created by Adam Amran on 05/09/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit

public protocol StoryboardType {
    static var name: String { get }
}

public struct StoryboardReference<S: StoryboardType, T> {
    
    private let id: String
    private let bundle: Bundle?
    
    public init(id: String, bundle: Bundle? = nil) {
        self.bundle = bundle
        self.id = id
    }
    
    public func instantiate() -> T {
        if let controller = UIStoryboard(name: S.name, bundle: bundle).instantiateViewController(withIdentifier: id) as? T {
            return controller
        } else {
            fatalError("Instantiated controller with \(id) has different type than expected!")
        }
    }
}
