//
//  TagsModalPresentationAnimator.swift
//  Collect
//
//  Created by Adam Amran on 05/09/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit

class TagsModalPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        toViewController.view.transform = CGAffineTransform(translationX: 0, y: 300)
        toViewController.view.layer.shadowColor = UIColor.black.cgColor
        toViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        toViewController.view.layer.shadowOpacity = 0.2
        toViewController.view.layer.cornerRadius = 10
        
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: animationDuration, animations: {
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: {
            finished in transitionContext.completeTransition(finished)
        })
        
    }
    
}
