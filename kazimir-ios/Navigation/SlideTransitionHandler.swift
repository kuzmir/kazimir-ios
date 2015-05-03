//
//  SlideTransitionHandler.swift
//  kazimir-ios
//
//  Created by Krzysiek on 03/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

protocol SlideTransitionHandlerDelegate {
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, didFinishTransition canceled: Bool)
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, segueIdentifierForDirection direction: SlideTransitionDirection) -> String
    
}

class SlideTransitionHandler: NSObject {
    
    var delegate: SlideTransitionHandlerDelegate!
    var transitionDirection: SlideTransitionDirection!
    
    func handleSlideTransitionWithinViewController(viewController: UIViewController, gestureRecognizer: UIPanGestureRecognizer) {
        let interactionTransition = (viewController.navigationController as? NavigationController)?.interactionTransition
        let gestureDirection: SlideTransitionDirection = gestureRecognizer.velocityInView(gestureRecognizer.view).x > 0 ? .Right : .Left
        
        switch (gestureRecognizer.state) {
        case .Began:
            transitionDirection = gestureDirection
            let segueIdentifier = delegate.slideTransitionHandler(self, segueIdentifierForDirection: transitionDirection!)
            viewController.performSegueWithIdentifier(segueIdentifier, sender: viewController)
        case .Changed:
            var progress = gestureRecognizer.translationInView(viewController.view).x / viewController.view.bounds.size.width
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
