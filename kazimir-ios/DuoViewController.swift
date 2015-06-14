//
//  DuoViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 05/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

enum EmbedSegueIdentifier: String {
    case First = "embedSeagueIdentifierFirst"
    case Second = "embedSeagueIdentifierSecond"
}

class DuoViewController: UIViewController {
    
    @IBOutlet var animator: Animator!
    
    private(set) var embededViewControllers = [UIViewController]()
    private(set) var visibleViewControllerIndex = 0
    
    func getVisibleViewController() -> UIViewController {
        return embededViewControllers[visibleViewControllerIndex]
    }
    
    func getHiddenViewController() -> UIViewController {
        return embededViewControllers[(visibleViewControllerIndex + 1) % 2]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController = self.getVisibleViewController()
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
        let visibleViewController = self.getVisibleViewController()
        let hiddenViewController = self.getHiddenViewController()
        
        self.addChildViewController(hiddenViewController)
        self.view.addSubview(hiddenViewController.view)
        
        animator.animate(fromViewController: visibleViewController, toViewController: hiddenViewController) { (finished) -> Void in
            if (finished) {
                visibleViewController.willMoveToParentViewController(nil)
                visibleViewController.view.removeFromSuperview()
                visibleViewController.removeFromParentViewController()
                
                hiddenViewController.didMoveToParentViewController(self)
                self.setNavigationItem(hiddenViewController.navigationItem)
                self.visibleViewControllerIndex = (self.visibleViewControllerIndex + 1) % 2
            }
            else {
                hiddenViewController.view.removeFromSuperview()
                hiddenViewController.removeFromParentViewController()
            }
        }
    }
}

extension DuoViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return (self.getVisibleViewController() as! BarTintColorChanging).getBarTintColor()
    }
    
}
