//
//  DetailViewControllerDraggable.swift
//  Collect
//
//  Created by Adham Amran on 12/10/2018.
//  Copyright © 2018 Adham Amran. All rights reserved.
//

import Foundation
import UIKit

class DetailViewControllerDraggable: UIViewController {
    var panGestureRecognizer: UIPanGestureRecognizer?
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureHandler))
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    @objc func gestureHandler(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            originalPosition = view.center
            currentPositionTouched = sender.location(in: view)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            }, completion: nil)
        } else if sender.state == .changed {
            view.frame.origin = CGPoint(x: 0, y: translation.y)
        } else if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            
            if velocity.y >= 1500 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.setStatusBarBackgroundColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.view.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = self.originalPosition!
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        self.view.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    }, completion: nil)
                })
            }
        }
    }
}
