//
//  TagsFlowLayout.swift
//  Collect
//
//  Created by Adham Amran on 06/09/2018.
//  Copyright © 2018 Adham Amran. All rights reserved.
//

import Foundation
import UIKit

class TagsFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()
                
        var leftMargin: CGFloat = 0.0;
        
        for attributes in attributesForElementsInRect! {
            if (attributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
            } else {
                var newLeftAlignedFrame = attributes.frame
                newLeftAlignedFrame.origin.x = leftMargin
                attributes.frame = newLeftAlignedFrame
            }
            leftMargin += attributes.frame.size.width + 8
            self.sectionInset.bottom = 10
            newAttributesForElementsInRect.append(attributes)
        }
        
        return newAttributesForElementsInRect
    }
}
