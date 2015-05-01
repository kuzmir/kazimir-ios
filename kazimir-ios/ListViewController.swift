//
//  ListViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    private var transitionDirection: SlideTransitionDirection?
    private var segueIdentifierOld = "pushItemViewControllerOld"
    private var segueIdentifierNew = "pushItemViewControllerNew"
    
    @IBAction func kazimirButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    @IBAction func panGestureRecognized(sender: UIPanGestureRecognizer) {
        let interactionTransition = (self.navigationController as? NavigationController)?.interactionTransition
        let gestureDirection: SlideTransitionDirection = sender.velocityInView(sender.view).x > 0 ? .Right : .Left
        
        switch (sender.state) {
        case .Began:
            transitionDirection = gestureDirection
            switch (transitionDirection!) {
            case .Left:
                self.performSegueWithIdentifier(segueIdentifierNew, sender: self)
            case .Right:
                self.performSegueWithIdentifier(segueIdentifierOld, sender: self)
            }
        case .Changed:
            var progress: CGFloat
            switch (transitionDirection!) {
            case .Right:
                progress = sender.translationInView(self.view).x / self.view.bounds.size.width
            case .Left:
                progress = -sender.translationInView(self.view).x / self.view.bounds.size.width
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let itemViewController = segue.destinationViewController as? ItemViewController {
            itemViewController.context = ItemContext(rawValue: transitionDirection!.rawValue)
        }
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listViewCell") as! UITableViewCell
        return cell
    }
    
}

extension ListViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)
            return abs(velocity.x) > abs(velocity.y)
        }
        return false;
    }
}

extension ListViewController: BarTintColorChanging {
    
    func barTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}
