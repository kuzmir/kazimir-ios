//
//  SlideTransition.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 29/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

enum SlideTransitionDirection: Int {
    case Right
    case Left
    
    func getOtherDirection() -> SlideTransitionDirection {
        return self == .Left ? .Right : .Left
    }
}

class SlideTransition: NSObject {
    
    let direction: SlideTransitionDirection
    let interactive: Bool
    
    init(direction: SlideTransitionDirection, interactive: Bool) {
        self.direction = direction
        self.interactive = interactive
        super.init()
    }
    
    func initialFrameForViewWithKey(key: String, withTransitionContext transitionContext: UIViewControllerContextTransitioning) -> CGRect {
        let bounds = transitionContext.containerView().bounds
        switch (key) {
        case UITransitionContextFromViewKey:
            return bounds
        case UITransitionContextToViewKey:
            var offset = bounds.size.width
            offset = self.direction == .Right ? -offset : offset
            return CGRectOffset(bounds, offset, 0)
        default:
            return CGRectZero
        }
    }
    
    func finalFrameForViewWithKey(key: String, withTransitionContext transitionContext: UIViewControllerContextTransitioning) -> CGRect {
        let bounds = transitionContext.containerView().bounds
        switch (key) {
        case UITransitionContextFromViewKey:
            var offset = bounds.size.width / 2
            offset = self.direction == .Right ? offset : -offset
            return CGRectOffset(bounds, offset, 0)
        case UITransitionContextToViewKey:
            return bounds
        default:
            return CGRectZero
        }
    }
   
}

extension SlideTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let duration = self.transitionDuration(transitionContext)
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        transitionContext.containerView().addSubview(toView)
        fromView.frame = self.initialFrameForViewWithKey(UITransitionContextFromViewKey, withTransitionContext: transitionContext)
        toView.frame = self.initialFrameForViewWithKey(UITransitionContextToViewKey, withTransitionContext: transitionContext)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            fromView.frame = self.finalFrameForViewWithKey(UITransitionContextFromViewKey, withTransitionContext: transitionContext)
            toView.frame = self.finalFrameForViewWithKey(UITransitionContextToViewKey, withTransitionContext: transitionContext)
            toViewController.navigationController?.navigationBar.barTintColor = (toViewController as! BarTintColorChanging).getBarTintColor()
        }) { (finished) -> Void in
            if (transitionContext.transitionWasCancelled()) {
                fromViewController.navigationController?.navigationBar.barTintColor = (fromViewController as! BarTintColorChanging).getBarTintColor()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
}
