//
//  MapViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var slideTransitionHandler: SlideTransitionHandler!
    
    var streetsFetchedResultsController: NSFetchedResultsController = Storage.sharedInstance.getStreetsFetchedResultsController()
    var polylines = [GMSPolyline]()
    var viewAppearsForFirstTime = true
    
    @IBAction func mapButtonTapped(sender: AnyObject) {
        let duoViewController = self.parentViewController as! DuoViewController
        duoViewController.switchViews()
    }
    
    @IBAction func kazimirButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideTransitionHandler.delegate = self
        streetsFetchedResultsController.performFetch(nil)
        
        pickerView.transform = CGAffineTransformMakeScale(1, 0.6)
        
        mapView.padding = UIEdgeInsetsMake(64, 0, 100, 0)
        mapView.myLocationEnabled = true
        
        for street in streetsFetchedResultsController.fetchedObjects as! [Street] {
            let polyline = self.createPolylineForStreet(street)
            polyline.map = mapView
            polylines.append(polyline)
        }
        self.updatePolylinesColors()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if viewAppearsForFirstTime {
            viewAppearsForFirstTime = false
            var bounds = GMSCoordinateBounds()
            for polyline in polylines {
                bounds = bounds.includingPath(polyline.path)
            }
            let cameraUpdate = GMSCameraUpdate.fitBounds(bounds)
            mapView.moveCamera(cameraUpdate)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let street = streetsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: pickerView.selectedRowInComponent(0), inSection: 0)) as! Street
        
        let duoViewController = segue.destinationViewController as! DuoViewController
        let firstItemViewController = duoViewController.embededViewControllers[0] as! ItemViewController
        firstItemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.rawValue)
        firstItemViewController.street = street
        let secondItemViewController = duoViewController.embededViewControllers[1] as! ItemViewController
        secondItemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.getOtherDirection().rawValue)
        secondItemViewController.street = street
    }
    
    private func createPolylineForStreet(street: Street) -> GMSPolyline {
        let path = GMSMutablePath()
        let coordinatesArray = street.path["coordinates"] as! [[NSNumber]]
        for coordinateArray in coordinatesArray {
            let latitude = coordinateArray[0].doubleValue
            let longitude = coordinateArray[1].doubleValue
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            path.addCoordinate(coordinate)
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        return polyline
    }
    
    private func updatePolylinesColors() {
        let selectedPolyline = polylines[pickerView.selectedRowInComponent(0)]
        for polyline in polylines {
            polyline.strokeColor = polyline == selectedPolyline ? Appearance.newColor : UIColor.darkGrayColor()
        }
    }
}

extension MapViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let sectionInfo = streetsFetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
}

extension MapViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 52
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let street = streetsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! Street
        let label = view as? UILabel ?? UILabel()
        label.text = street.name
        label.font = UIFont(name: "OpenSans-Bold", size: UIFont.systemFontSize())
        label.textAlignment = .Center
        label.transform = CGAffineTransformMakeScale(1, 1 / 0.6)
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedPolyline = polylines[row]
        let bounds = GMSCoordinateBounds(path: selectedPolyline.path)
        let cameraUpdate = GMSCameraUpdate.fitBounds(bounds)
        mapView.animateWithCameraUpdate(cameraUpdate)
        self.updatePolylinesColors()
    }
    
}

extension MapViewController: SlideTransitionHandlerDelegate {
    
    func viewControllerForSlideTransitionHandler(slideTransitionHandler: SlideTransitionHandler) -> UIViewController {
        return self.parentViewController!
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

extension MapViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}