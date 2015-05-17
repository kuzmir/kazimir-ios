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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideTransitionHandler.delegate = self
        streetsFetchedResultsController.delegate = self
        streetsFetchedResultsController.performFetch(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let indexPath = tableView.indexPathForRowAtPoint(slideTransitionHandler.location)!
        let street = streetsFetchedResultsController.objectAtIndexPath(indexPath) as! Street
        
        let duoViewController = segue.destinationViewController as! DuoViewController
        let firstItemViewController = duoViewController.embededViewControllers[0] as! ItemViewController
        firstItemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.rawValue)
        firstItemViewController.streetFetchedResultsController = Storage.sharedInstance.getStreetFetchedResultsController(streetId: street.id)
        let secondItemViewController = duoViewController.embededViewControllers[1] as! ItemViewController
        secondItemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.getOtherDirection().rawValue)
        secondItemViewController.streetFetchedResultsController = Storage.sharedInstance.getStreetFetchedResultsController(streetId: street.id)
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
        imageView.image = photo != nil ? UIImage(data: photo!.dataMedium) : UIImage(named: "kazimir_neutral")

        return cell
    }
    
}

extension ListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
}

extension ListViewController: SlideTransitionHandlerDelegate {
    
    func viewControllerForSlideTransitionHandler(slideTransitionHandler: SlideTransitionHandler) -> UIViewController {
        return self.parentViewController!
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, shouldBeginInLocation location: CGPoint) -> Bool {
        return tableView.indexPathForRowAtPoint(location) != nil
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, segueIdentifierForDirection direction: SlideTransitionDirection) -> String {
        switch (direction) {
        case .Left:
            return ItemContext.Old.getSegueIdentifier()
        case .Right:
            return ItemContext.New.getSegueIdentifier()
        }
    }
    
}

extension ListViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}
