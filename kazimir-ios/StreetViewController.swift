//
//  StreetViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

class StreetViewController: UIViewController {
    
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slideTransitionHandler: SlideTransitionHandler!
    
    var timeContext: TimeContext!
    var streetFetchedResultsController: NSFetchedResultsController!
    var interactiveTransition: Bool!
    
    var street: Street? {
        return streetFetchedResultsController.fetchedObjects?[0] as? Street
    }
    
    var popDirection: SlideTransitionDirection {
        return SlideTransitionDirection(rawValue: timeContext.getOppositeTimeContext().rawValue)!
    }
    
    var pushDirection: SlideTransitionDirection {
        return SlideTransitionDirection(rawValue: timeContext.rawValue)!
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func flipButtonTapped(sender: AnyObject) {
        let duoViewController = self.parentViewController as! DuoViewController
        duoViewController.switchViews()
    }
    
    @IBAction func tapGestureRecognized(sender: UITapGestureRecognizer) {
        if let indexPath = tableView.indexPathForRowAtPoint(sender.locationInView(tableView)) {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let galleryView = cell.viewWithTag(1) as! GalleryView
            if galleryView.frame.contains(sender.locationInView(galleryView.superview)) {
                let places = self.getPlacesFromStreet(street, timeContext: timeContext)
                if places![indexPath.row].photos.count > 0 {
                    let photo = places![indexPath.row].photos[galleryView.index] as? Photo
                    self.performSegueWithIdentifier("showPhoto", sender: photo)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideTransitionHandler.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 96, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 311
        
        flipButton.setImage(UIImage(named: timeContext.getImageName()), forState: .Normal)
        
        streetFetchedResultsController.delegate = self
        streetFetchedResultsController.performFetch(nil)
        
        self.navigationItem.title = street?.name
        self.navigationItem.hidesBackButton = true
        if timeContext.rawValue == SlideTransitionDirection.Right.rawValue {
            self.navigationItem.leftBarButtonItem = nil
        }
        if timeContext.rawValue == SlideTransitionDirection.Left.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        switch segue.identifier! {
            case "showPhoto":
            let photoViewController = segue.destinationViewController as! PhotoViewController
            photoViewController.photo = sender as! Photo
        default:
            break
        }
    }
    
    private func getPlacesFromStreet(street: Street?, timeContext: TimeContext) -> [Place]? {
        if street == nil { return nil }
        return (street!.places.array as! [Place]).filter {
            return TimeContext.getTimeContextForPlace($0) == timeContext
        }
    }
    
    private func getNameFromPlace(place: Place, locale: String) -> String? {
        let details = place.details[locale] as? [String: String]
        let name = details?["name"]
        if name == nil { return nil }
        return name!.isEmpty ? nil : name
    }
    
    private func getDescriptionFromPlace(place: Place, locale: String) -> String? {
        let details = place.details[locale] as? [String: String]
        let description = details?["description"]
        if description == nil { return nil }
        return description!.isEmpty ? nil : description
    }
    
}

extension StreetViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getPlacesFromStreet(street, timeContext: timeContext)?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let places = self.getPlacesFromStreet(street!, timeContext: timeContext)!
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell") as! UITableViewCell
        let place = places[indexPath.row]
        
        let galleryView = cell.viewWithTag(1) as! GalleryView
        galleryView.clear()
        for photo in place.photos.array as! [Photo] {
            let image = UIImage(data: photo.dataSmall)!
            galleryView.addImage(image)
        }
        
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let placeName = self.getNameFromPlace(place, locale: Appearance.getLocale())
        nameLabel.text = placeName != nil ? placeName : "..."
        
        let descriptionLabel = cell.viewWithTag(3) as! UILabel
        let placeDescription = self.getDescriptionFromPlace(place, locale: Appearance.getLocale())
        descriptionLabel.text = placeDescription != nil ? placeDescription : "..."

        return cell
    }
    
}

extension StreetViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let unwrappedStreet = street {
            self.navigationItem.title = unwrappedStreet.name
            self.tableView.reloadData()
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

extension StreetViewController: SlideTransitionHandlerDelegate {
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, shouldBeginInLocation location: CGPoint, withDirection direction: SlideTransitionDirection) -> Bool {
        return direction != self.pushDirection
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, performTransitionWithLocation location: CGPoint, andDirection direction: SlideTransitionDirection) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension StreetViewController: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransition(direction: self.pushDirection.getOppositeDirection(), interactive: slideTransitionHandler.percentDrivenInteractiveTransition != nil)
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return slideTransitionHandler.percentDrivenInteractiveTransition
    }
    
}

extension StreetViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return timeContext == .Old ? Appearance.oldColor : Appearance.newColor
    }
    
}
