//
//  NavigationController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    var interactionTransition: UIPercentDrivenInteractiveTransition?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }

}

extension NavigationController: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch ((fromVC, toVC)) {
        case let (_, toVC as DuoViewController) where toVC.visibleViewController is ItemViewController:
            let itemViewController = toVC.visibleViewController as! ItemViewController
            return SlideTransition(direction: itemViewController.pushDirection, interactive: true)
        case let (fromVC as DuoViewController, _) where fromVC.visibleViewController is ItemViewController:
            let itemViewController = fromVC.visibleViewController as! ItemViewController
            return SlideTransition(direction: itemViewController.popDirection, interactive: false)
        default:
            return nil
        }
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch (animationController) {
        case let animationController as SlideTransition where animationController.interactive:
            interactionTransition = UIPercentDrivenInteractiveTransition()
        default:
            interactionTransition = nil
        }
        return interactionTransition
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        interactionTransition = nil
    }
    
}