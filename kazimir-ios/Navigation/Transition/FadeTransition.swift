//
//  FadeTransition.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 16/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class FadeTransition: NSObject {
   
}

extension FadeTransition: UIViewControllerAnimatedTransitioning {
    
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
        toView.alpha = 0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            toView.alpha = 1
        }) { (finished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
}
