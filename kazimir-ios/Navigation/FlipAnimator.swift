//
//  FlipAnimator.swift
//  kazimir-ios
//
//  Created by Krzysiek on 01/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class FlipAnimator: Animator {
    
    override func animate(#fromViewController: UIViewController, toViewController: UIViewController, completionHandler: (Bool) -> Void) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            UIView.transitionFromView(fromViewController.view, toView: toViewController.view, duration: 0.5, options:.TransitionFlipFromLeft, completion: nil)
            toViewController.navigationController?.navigationBar.barTintColor = (toViewController as! BarTintColorChanging).getBarTintColor()
        }) { (finished) -> Void in
            if (!finished) {
                fromViewController.navigationController?.navigationBar.barTintColor = (fromViewController as! BarTintColorChanging).getBarTintColor()
            }
            completionHandler(finished)
        }
    }
   
}