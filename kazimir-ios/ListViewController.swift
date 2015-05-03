//
//  ListViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    var slideTransitionHandler: SlideTransitionHandler?
    
    private var segueIdentifierOld = "pushItemViewControllerOld"
    private var segueIdentifierNew = "pushItemViewControllerNew"
    
    @IBAction func kazimirButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    @IBAction func panGestureRecognized(sender: UIPanGestureRecognizer) {
        switch (sender.state) {
        case .Began:
            slideTransitionHandler = SlideTransitionHandler()
            slideTransitionHandler!.delegate = self
            fallthrough
        default:
            slideTransitionHandler!.handleSlideTransitionWithinViewController(self, gestureRecognizer: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let itemViewController = segue.destinationViewController as? ItemViewController {
            itemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.rawValue)
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

extension ListViewController: SlideTransitionHandlerDelegate {
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, didFinishTransition canceled: Bool) {
        self.slideTransitionHandler = nil
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, segueIdentifierForDirection direction: SlideTransitionDirection) -> String {
        switch (direction) {
        case .Left:
            return segueIdentifierOld
        case .Right:
            return segueIdentifierNew
        }
    }
    
}

extension ListViewController: BarTintColorChanging {
    
    func barTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}
