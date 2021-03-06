//
//  MapViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var slideTransitionHandler: SlideTransitionHandler!
    @IBOutlet weak var leftArrowButton: UIButton!
    
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
    
    @IBAction func leftArrowButtonTapped(sender: UIButton) {
        self.parentViewController!.performSegueWithIdentifier(TimeContext.Old.getSegueIdentifier(), sender: sender)
    }
    
    @IBAction func rightArrowButtonTapped(sender: UIButton) {
        self.parentViewController!.performSegueWithIdentifier(TimeContext.New.getSegueIdentifier(), sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideTransitionHandler.delegate = self
        streetsFetchedResultsController.delegate = self
        streetsFetchedResultsController.performFetch(nil)
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            CLLocationManager().requestWhenInUseAuthorization()
        }
        
        mapView.delegate = self
        mapView.padding = UIEdgeInsetsMake(64, 0, 162, 0)
        mapView.myLocationEnabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
        if viewAppearsForFirstTime {
            viewAppearsForFirstTime = false
            self.reloadStreetsOnMap()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let street = streetsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: pickerView.selectedRowInComponent(0), inSection: 0)) as! Street
        
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
    
    private func reloadStreetsOnMap() {
        mapView.clear()
        polylines.removeAll(keepCapacity: false)
        
        var bounds = GMSCoordinateBounds()
        for street in streetsFetchedResultsController.fetchedObjects as! [Street] {
            let polyline = self.createPolylineForStreet(street)
            polyline.tappable = true
            polyline.map = mapView
            polylines.append(polyline)
            bounds = bounds.includingPath(polyline.path)
        }
        
        if polylines.count > 0 {
            self.updatePolylinesColors()
            let cameraUpdate = GMSCameraUpdate.fitBounds(bounds)
            mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func createPolylineForStreet(street: Street) -> GMSPolyline {
        let path = GMSMutablePath()
        let coordinatesArray = street.path["coordinates"] as! [[NSNumber]]
        for coordinateArray in coordinatesArray {
            let latitude = coordinateArray[0].doubleValue
            let longitude = coordinateArray[1].doubleValue
            path.addCoordinate(CLLocationCoordinate2DMake(latitude, longitude))
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
    
    private func selectPolyline(polyline: GMSPolyline) {
        let index = find(polylines, polyline)!
        pickerView.selectRow(index, inComponent: 0, animated: true)
        let bounds = GMSCoordinateBounds(path: polyline.path)
        let cameraUpdate = GMSCameraUpdate.fitBounds(bounds)
        mapView.animateWithCameraUpdate(cameraUpdate)
        self.updatePolylinesColors()
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        let selectedPolyline = overlay as! GMSPolyline
        self.selectPolyline(selectedPolyline)
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
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let street = streetsFetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! Street
        let label = view as? UILabel ?? UILabel()
        label.text = street.name
        label.font = UIFont(name: "OpenSans-Bold", size: UIFont.systemFontSize())
        label.textAlignment = .Center
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedPolyline = polylines[row]
        self.selectPolyline(selectedPolyline)
    }
    
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        pickerView.reloadAllComponents()
        self.reloadStreetsOnMap()
    }
    
}

extension MapViewController: SlideTransitionHandlerDelegate {
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, shouldBeginInLocation location: CGPoint, withDirection direction: SlideTransitionDirection) -> Bool {
        return true
    }
    
    func slideTransitionHandler(slideTransitionHandler: SlideTransitionHandler, performTransitionWithLocation location: CGPoint, andDirection direction: SlideTransitionDirection) {
        let segueIdentifier = direction == .Left ? TimeContext.New.getSegueIdentifier() : TimeContext.Old.getSegueIdentifier()
        self.parentViewController?.performSegueWithIdentifier(segueIdentifier, sender: nil)
    }
    
}

extension MapViewController: UINavigationControllerDelegate {
    
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

extension MapViewController: BarTintColorChanging {
    
    func getBarTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}