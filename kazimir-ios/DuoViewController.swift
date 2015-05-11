//
//  DuoViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 05/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

enum EmbedSegueIdentifier: String {
    case First = "embedSeagueIdentifierFirst"
    case Second = "embedSeagueIdentifierSecond"
}

class DuoViewController: UIViewController {
    
    @IBOutlet var animator: Animator!
    
    var embededViewControllers = [UIViewController]()
    var visibleViewControllerIndex = 0
    var visibleViewController: UIViewController {
        return embededViewControllers[visibleViewControllerIndex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController = visibleViewController
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        self.setNavigationItem(viewController.navigationItem)
        viewController.didMoveToParentViewController(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        switch (segue.identifier!) {
        case EmbedSegueIdentifier.First.rawValue, EmbedSegueIdentifier.Second.rawValue:
            let embededViewController = segue.destinationViewController as! UIViewController
            self.embededViewControllers.append(embededViewController)
        default:
            embededViewControllers[visibleViewControllerIndex].prepareForSegue(segue, sender: sender)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        performSegueWithIdentifier(EmbedSegueIdentifier.First.rawValue, sender: self)
        performSegueWithIdentifier(EmbedSegueIdentifier.Second.rawValue, sender: self)
    }
    
    private func setNavigationItem(navigationItem :UINavigationItem) {
        self.navigationItem.title = navigationItem.title
        self.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem
        self.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        self.navigationItem.hidesBackButton = navigationItem.hidesBackButton
    }
    
    func switchViews() {
        let newVisibleViewControllerIndex = (visibleViewControllerIndex + 1) % 2
        let visibleViewController = embededViewControllers[visibleViewControllerIndex]
        let newVisibleViewController = embededViewControllers[newVisibleViewControllerIndex]
        
        self.addChildViewController(newVisibleViewController)
        self.view.addSubview(newVisibleViewController.view)
        
        animator.animate(fromViewController: visibleViewController, toViewController: newVisibleViewController) { (finished) -> Void in
            if (finished) {
                visibleViewController.willMoveToParentViewController(nil)
                visibleViewController.view.removeFromSuperview()
                visibleViewController.removeFromParentViewController()
                
                newVisibleViewController.didMoveToParentViewController(self)
                self.setNavigationItem(newVisibleViewController.navigationItem)
                self.visibleViewControllerIndex = newVisibleViewControllerIndex
            }
            else {
                newVisibleViewController.view.removeFromSuperview()
                newVisibleViewController.removeFromParentViewController()
            }
        }
    }
}

extension DuoViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return (self.visibleViewController as! BarTintColorChanging).getBarTintColor()
    }
    
}
