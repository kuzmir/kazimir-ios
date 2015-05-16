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
    
    func getImageName() -> String {
        return self == .Old ? "button_flip_old" : "button_flip_new"
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
    
    var locale: String = {
        let localizations = NSBundle.mainBundle().preferredLocalizations as! [String]
        let currentLocale =  NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
        return contains(localizations,currentLocale) ? currentLocale : localizations[0]
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 72, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        
        flipButton.setImage(UIImage(named: context.getImageName()), forState: .Normal)
        
        streetFetchedResultsController.delegate = self
        streetFetchedResultsController.performFetch(nil)
        
        self.navigationItem.title = self.getStreet()?.name
        self.navigationItem.hidesBackButton = true
        if context.rawValue == SlideTransitionDirection.Right.rawValue {
            self.navigationItem.leftBarButtonItem = nil
        }
        if context.rawValue == SlideTransitionDirection.Left.rawValue {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func getStreet() -> Street? {
        return streetFetchedResultsController.fetchedObjects?[0] as? Street
    }
    
    private func getPlacesFromStreet(street: Street, context: ItemContext) -> [Place] {
        var places = [Place]()
        for place in street.places.array as! [Place] {
            let placeContext = place.present.boolValue ? ItemContext.New : ItemContext.Old
            if placeContext == context {
                places.append(place)
            }
        }
        return places
    }
    
    private func getNameFromPlace(place: Place, locale: String) -> String? {
        let details = place.details[locale] as? [String: String]
        return details?["name"]
    }
    
    private func getDescriptionFromPlace(place: Place, locale: String) -> String? {
        let details = place.details[locale] as? [String: String]
        return details?["description"]
    }
    
}

extension ItemViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let street = self.getStreet()
        return street != nil ? self.getPlacesFromStreet(street!, context: context).count : 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getStreet() != nil ? 1 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeCell") as! UITableViewCell
        if let street = self.getStreet() {
            let place = self.getPlacesFromStreet(street, context: context)[indexPath.section]
            let nameLabel = cell.viewWithTag(1) as! UILabel
            let descriptionLabel = cell.viewWithTag(2) as! UILabel
            
            nameLabel.text = self.getNameFromPlace(place, locale: locale)
            descriptionLabel.text = self.getDescriptionFromPlace(place, locale: locale)
        }
        return cell
    }
    
}

extension ItemViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("galleryCell") as! UITableViewCell
        if let street = getStreet() {
            let place = self.getPlacesFromStreet(street, context: context)[section]
            let galleryView = header.viewWithTag(1) as! GalleryView
            
            galleryView.clear()
            for photo in place.photos.array as! [Photo] {
                let image = UIImage(data: photo.dataMedium)!
                galleryView.addImage(image)
            }
        }
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
}

extension ItemViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.navigationItem.title = self.getStreet()?.name
        self.tableView.reloadData()
    }
    
}

extension ItemViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return context == .Old ? Appearance.oldColor : Appearance.newColor
    }
    
}
