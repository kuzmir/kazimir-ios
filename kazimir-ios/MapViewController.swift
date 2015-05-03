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
    
    @IBAction func mapButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func kazimirButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.transform = CGAffineTransformMakeScale(1, 0.6)
        
        var camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6)
        mapView.animateToCameraPosition(camera)
        mapView.myLocationEnabled = true
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        mapView.padding = UIEdgeInsetsMake(100, 0, 100, 0)
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

extension MapViewController: BarTintColorChanging {
    
    func barTintColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}