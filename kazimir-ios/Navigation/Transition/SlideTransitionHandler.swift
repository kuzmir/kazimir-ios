//
//  SlideTransitionHandler.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 03/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

protocol SlideTransitionHandlerDelegate {
    
    func viewControllerForSlideTransitionHandler(slideTransitionHandler: SlideTransitionHandler) -> UIViewController
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, shouldBeginInLocation location: CGPoint) -> Bool
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, segueIdentifierForDirection direction: SlideTransitionDirection) -> String
    
}

class SlideTransitionHandler: NSObject {
    
    var delegate: SlideTransitionHandlerDelegate!
    var location: CGPoint!
    var transitionDirection: SlideTransitionDirection!
    
    @IBAction func panGestureRecognized(sender: UIPanGestureRecognizer) {
        let viewController = delegate.viewControllerForSlideTransitionHandler(self)
        let interactionTransition = (viewController.navigationController as? NavigationController)?.interactionTransition
        let gestureDirection: SlideTransitionDirection = sender.velocityInView(sender.view).x > 0 ? .Right : .Left
        
        switch (sender.state) {
        case .Began:
            transitionDirection = gestureDirection
            let segueIdentifier = delegate.slideTransitionHandler(self, segueIdentifierForDirection: transitionDirection!)
            viewController.performSegueWithIdentifier(segueIdentifier, sender: viewController)
        case .Changed:
            var progress = sender.translationInView(viewController.view).x / viewController.view.bounds.size.width
            if (transitionDirection! == .Left) {
                progress = -progress
            }
            interactionTransition?.updateInteractiveTransition(progress)
        case .Ended, .Cancelled:
            switch ((transitionDirection, gestureDirection)) {
            case let (transitionDirection, gestureDirection) where transitionDirection == gestureDirection:
                interactionTransition?.finishInteractiveTransition()
            default:
                interactionTransition?.cancelInteractiveTransition()
            }
        default: break
        }
    }
   
}

extension SlideTransitionHandler: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)
            if abs(velocity.x) > abs(velocity.y) {
                let location = panGestureRecognizer.locationInView(panGestureRecognizer.view)
                if delegate.slideTransitionHandler(self, shouldBeginInLocation: location) {
                    self.location = location
                    return true
                }
            }
        }
        return false;
    }
}
