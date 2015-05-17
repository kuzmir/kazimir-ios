//
//  ImageViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 17/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo!
    
    @IBAction func tapGestureRecognized(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(data: photo.dataLarge)
    }

}
