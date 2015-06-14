//
//  ItemViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

enum ItemContext: Int {
    case Old
    case New
}

extension ItemContext {
    
    static func getContextFromPlace(place: Place) -> ItemContext {
        return place.present.boolValue ? ItemContext.New : ItemContext.Old
    }
    
    func getImageName() -> String {
        return self == .Old ? "button_flip_new" : "button_flip_old"
    }
    
    func getSegueIdentifier() -> String {
        return self == .Old ? "pushItemViewControllerOld" : "pushItemViewControllerNew"
    }
    
    func getOtherContext() -> ItemContext {
        return self == .Old ? .New : .Old
    }
    
}

class ItemViewController: UIViewController {
    
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var context: ItemContext!
    var streetFetchedResultsController: NSFetchedResultsController!
    var interactiveTransition: Bool!
    
    var street: Street! {
        return streetFetchedResultsController.fetchedObjects![0] as! Street
    }
    
    var popDirection: SlideTransitionDirection {
        return SlideTransitionDirection(rawValue: context.getOtherContext().rawValue)!
    }
    
    var pushDirection: SlideTransitionDirection {
        return SlideTransitionDirection(rawValue: context.rawValue)!
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
                let places = self.getPlacesFromStreet(street!, context: context)
                let photo = places[indexPath.row].photos[galleryView.index] as! Photo
                self.performSegueWithIdentifier("showPhoto", sender: photo)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 96, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 311
        
        flipButton.setImage(UIImage(named: context.getImageName()), forState: .Normal)
        
        streetFetchedResultsController.delegate = self
        streetFetchedResultsController.performFetch(nil)
        
        self.navigationItem.title = street?.name
        self.navigationItem.hidesBackButton = true
        if context.rawValue == SlideTransitionDirection.Right.rawValue {
            self.navigationItem.leftBarButtonItem = nil
        }
        if context.rawValue == SlideTransitionDirection.Left.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
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
    
    private func getPlacesFromStreet(street: Street, context: ItemContext) -> [Place] {
        return (street.places.array as! [Place]).filter {
            return ItemContext.getContextFromPlace($0) == context
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

extension ItemViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getPlacesFromStreet(street, context: context).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let places = self.getPlacesFromStreet(street!, context: context)
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

extension ItemViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.navigationItem.title = street?.name
        self.tableView.reloadData()
    }
    
}

extension ItemViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return context == .Old ? Appearance.oldColor : Appearance.newColor
    }
    
}
