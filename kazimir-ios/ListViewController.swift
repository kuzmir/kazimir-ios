//
//  ListViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var slideTransitionHandler: SlideTransitionHandler!
    
    var streetsFetchedResultsController: NSFetchedResultsController = Storage.sharedInstance.getStreetsFetchedResultsController()
    
    @IBAction func kazimirButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    @IBAction func mapButtonTapped(sender: AnyObject) {
        let duoViewController = self.parentViewController as! DuoViewController
        duoViewController.switchViews()
    }
    
    @IBAction func leftArrowButtonTapped(sender: UIButton) {
        let indexPath = tableView.indexPathForRowAtPoint(sender.convertPoint(CGPointZero, toView: tableView))!
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        self.parentViewController!.performSegueWithIdentifier(TimeContext.Old.getSegueIdentifier(), sender: cell)
    }
    
    @IBAction func rightArrowButtonTapped(sender: UIButton) {
        let indexPath = tableView.indexPathForRowAtPoint(sender.convertPoint(CGPointZero, toView: tableView))!
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        self.parentViewController!.performSegueWithIdentifier(TimeContext.New.getSegueIdentifier(), sender: cell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideTransitionHandler.delegate = self
        streetsFetchedResultsController.delegate = self
        streetsFetchedResultsController.performFetch(nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
        let street = streetsFetchedResultsController.objectAtIndexPath(indexPath) as! Street
        
        let duoViewController = segue.destinationViewController as! DuoViewController
        let firstStreetViewController = duoViewController.embededViewControllers[0] as! StreetViewController
        firstStreetViewController.streetFetchedResultsController = Storage.sharedInstance.getStreetFetchedResultsController(streetId: street.id)
        firstStreetViewController.interactiveTransition = !(sender is UIButton)
        firstStreetViewController.timeContext = TimeContext.getTimeContextFromSegueIdentifier(segue.identifier!)
        
        let secondStreetViewController = duoViewController.embededViewControllers[1] as! StreetViewController
        secondStreetViewController.streetFetchedResultsController = Storage.sharedInstance.getStreetFetchedResultsController(streetId: street.id)
        secondStreetViewController.interactiveTransition = !(sender is UIButton)
        secondStreetViewController.timeContext = firstStreetViewController.timeContext.getOppositeTimeContext()
    }
    
    private func getPhotoFromStreet(street: Street) -> Photo? {
        let place = street.places.count > 0 ? street.places[0] as? Place : nil
        if place == nil { return nil }
        return place!.photos.count > 0 ? place!.photos[0] as? Photo : nil
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = streetsFetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let street = streetsFetchedResultsController.objectAtIndexPath(indexPath) as! Street
        let cell = tableView.dequeueReusableCellWithIdentifier("listViewCell") as! UITableViewCell
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = street.name
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        let photo = self.getPhotoFromStreet(street)
        imageView.image = photo != nil ? UIImage(data: photo!.dataSmall) : UIImage(named: "kazimir_neutral")

        return cell
    }
    
}

extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
}

extension ListViewController: SlideTransitionHandlerDelegate {
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, shouldBeginInLocation location: CGPoint, withDirection direction: SlideTransitionDirection) -> Bool {
        return true
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, performTransitionWithLocation location: CGPoint, andDirection direction: SlideTransitionDirection) {
        let indexPath = self.tableView.indexPathForRowAtPoint(location)!
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        let segueIdentifier = direction == .Left ? TimeContext.New.getSegueIdentifier() : TimeContext.Old.getSegueIdentifier()
        self.parentViewController?.performSegueWithIdentifier(segueIdentifier, sender: cell)
    }
    
}

extension ListViewController: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let toVC = toVC as? DuoViewController {
            let streetViewController = toVC.getVisibleViewController() as! StreetViewController
            return SlideTransition(direction: streetViewController.pushDirection, interactive: slideTransitionHandler.percentDrivenInteractiveTransition != nil)
        }
        return FadeTransition()
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return slideTransitionHandler.percentDrivenInteractiveTransition
    }
    
}

extension ListViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}
