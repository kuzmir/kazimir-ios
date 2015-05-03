//
//  MapViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var slideTransitionHandler: SlideTransitionHandler?
    
    private var segueIdentifierOld = "pushItemViewControllerOld"
    private var segueIdentifierNew = "pushItemViewControllerNew"
    
    @IBAction func mapButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func kazimirButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.padding = UIEdgeInsetsMake(100, 0, 100, 0)
        pickerView.transform = CGAffineTransformMakeScale(1, 0.6)
        
        var camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6)
        mapView.animateToCameraPosition(camera)
        mapView.myLocationEnabled = true
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let itemViewController = segue.destinationViewController as? ItemViewController {
            itemViewController.context = ItemContext(rawValue: slideTransitionHandler!.transitionDirection.rawValue)
        }
    }
}

extension MapViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
}

extension MapViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 52
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        if (view != nil) {
            return view
        }
    
        let label = UILabel()
        label.font = UIFont(name: "OpenSans-Bold", size: UIFont.systemFontSize())
        label.text = "PLAC NOWY"
        label.textAlignment = .Center
        label.transform = CGAffineTransformMakeScale(1, 1 / 0.6)
        return label
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer:UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)
            return abs(velocity.x) > abs(velocity.y)
        }
        return false;
    }
}

extension MapViewController: SlideTransitionHandlerDelegate {
    
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

extension MapViewController: BarTintColorChanging {
    
    func barTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}