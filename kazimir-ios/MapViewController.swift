//
//  MapViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 18/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        mapButton.target = self
        mapButton.action = "mapButtonTapped"
    }
    
    func mapButtonTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
