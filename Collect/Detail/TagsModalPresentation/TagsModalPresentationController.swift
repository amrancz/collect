//
//  TagsModalPresentationController.swift
//  Collect
//
//  Created by Adam Amran on 05/09/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit

final class TagsModalPresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    @objc func dismiss(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController!) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedViewController.modalPresentationStyle = .custom
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: UIScreen.main.bounds.height - 332, width: UIScreen.main.bounds.width, height: 332)
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0.2
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.layer.masksToBounds = true
        presentedView!.layer.cornerRadius = 10
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
}
