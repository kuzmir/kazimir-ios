//
//  ListViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
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
        streetsFetchedResultsController.performFetch(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let duoViewController = segue.destinationViewController as! DuoViewController
        let firstItemViewController = duoViewController.embededViewControllers[0] as! ItemViewController
        firstItemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.rawValue)
        let secondItemViewController = duoViewController.embededViewControllers[1] as! ItemViewController
        secondItemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.getOtherDirection().rawValue)
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = streetsFetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let street = streetsFetchedResultsController.objectAtIndexPath(indexPath) as! Street
        let place = street.places[0] as! Place
        let photo = place.photos[0] as! Photo
        
        let cell = tableView.dequeueReusableCellWithIdentifier("listViewCell") as! UITableViewCell
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(data: photo.dataMedium)
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = street.name
        return cell
    }
    
}

extension ListViewController: SlideTransitionHandlerDelegate {
    
    func viewControllerForSlideTransitionHandler(slideTransitionHandler: SlideTransitionHandler) -> UIViewController {
        return self.parentViewController!
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, segueIdentifierForDirection direction: SlideTransitionDirection) -> String {
        switch (direction) {
        case .Left:
            return SegueIdentifier.Old.rawValue
        case .Right:
            return SegueIdentifier.New.rawValue
        }
    }
    
}

extension ListViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}
