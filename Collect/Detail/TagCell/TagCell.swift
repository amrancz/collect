//
//  TagCell.swift
//  Collect
//
//  Created by Adam Amran on 27/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet  var tagCellLabel: UILabel!
    @IBOutlet weak var tagCellMaxWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.layer.cornerRadius = 5
        self.tagCellMaxWidth.constant = UIScreen.main.bounds.width - 8 * 2 - 8 * 2
    }
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected {
                tagCellLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.backgroundColor = #colorLiteral(red: 0, green: 0.4, blue: 0.8274509804, alpha: 1)
                    self.layer.borderWidth = 0
                }, completion: nil)
            }
            else {
                tagCellLabel.textColor = #colorLiteral(red: 0.1777849495, green: 0.1777901053, blue: 0.1777873635, alpha: 1)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    self.layer.borderWidth = 1
                    self.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
                    self.layer.cornerRadius = 5
                }, completion: nil)
            }
        }
    }
}

