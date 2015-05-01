//
//  NavigationControllerViewController.swift
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
        case let (fromVC as ItemViewController, toVC as ItemViewController):
            return FlipTransition()
        case let (_, toVC as ItemViewController):
            return SlideTransition(direction: toVC.pushDirection, interactive: true)
        case let (fromVC as ItemViewController, _):
            return SlideTransition(direction: fromVC.popDirection, interactive: false)
        default:
            return FadeTransition()
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