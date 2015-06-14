//
//  SlideTransitionHandler.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 03/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

protocol SlideTransitionHandlerDelegate {
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, shouldBeginInLocation location: CGPoint, withDirection direction: SlideTransitionDirection) -> Bool
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, performTransitionWithLocation location: CGPoint, andDirection direction: SlideTransitionDirection)
    
}

class SlideTransitionHandler: NSObject {
    
    private(set) var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?
    private(set) var direction: SlideTransitionDirection?
    private(set) var location: CGPoint?
    
    var delegate: SlideTransitionHandlerDelegate!
    
    
    @IBAction func panGestureRecognized(sender: UIPanGestureRecognizer) {
        let gestureLocation = sender.locationInView(sender.view!)
        let gestureVelocity = sender.velocityInView(sender.view!)
        let gestureDirection = gestureVelocity.x > 0 ? SlideTransitionDirection.Right : .Left
        
        switch (sender.state) {
        case .Began:
            location = gestureLocation
            direction = gestureDirection
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            delegate.slideTransitionHandler(self, performTransitionWithLocation: location!, andDirection: direction!)
        case .Changed:
            var progress = sender.translationInView(sender.view!).x / sender.view!.bounds.size.width
            progress = direction! == .Left ? -progress : progress
            percentDrivenInteractiveTransition?.updateInteractiveTransition(progress)
        case .Ended, .Cancelled:
            if direction == gestureDirection { percentDrivenInteractiveTransition?.finishInteractiveTransition() }
            else { percentDrivenInteractiveTransition?.cancelInteractiveTransition() }
            percentDrivenInteractiveTransition = nil
            location = nil
            direction = nil
        default: break
        }
    }
   
}

extension SlideTransitionHandler: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let gestureVelocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)
            if abs(gestureVelocity.x) > abs(gestureVelocity.y) {
                let gestureLocation = panGestureRecognizer.locationInView(panGestureRecognizer.view)
                let gestureDirection = gestureVelocity.x > 0 ? SlideTransitionDirection.Right : .Left
                return delegate.slideTransitionHandler(self, shouldBeginInLocation: gestureLocation, withDirection: gestureDirection)
            }
        }
        return false;
    }
    
}
