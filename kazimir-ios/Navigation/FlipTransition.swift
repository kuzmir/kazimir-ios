//
//  FlipTransition.swift
//  kazimir-ios
//
//  Created by Krzysiek on 01/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class FlipTransition: NSObject {
   
}

extension FlipTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let duration = self.transitionDuration(transitionContext)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        transitionContext.containerView().addSubview(toViewController!.view)
        toViewController?.view.alpha = 0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            toViewController?.view.alpha = 1
            }) { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
}
