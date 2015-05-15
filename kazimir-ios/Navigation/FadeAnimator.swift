//
//  FadeAnimator.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class FadeAnimator: Animator {
    
    override func animate(#fromViewController: UIViewController, toViewController: UIViewController, completionHandler: (Bool) -> Void) {
        toViewController.view.alpha = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            toViewController.view.alpha = 1
            }) { (finished) -> Void in
                completionHandler(finished)
        }
    }
    
}