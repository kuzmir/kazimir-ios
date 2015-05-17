//
//  ImageViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 17/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var photo: Photo!
    var imageView: UIImageView!
    
    @IBAction func tapGestureRecognized(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(data: photo.dataLarge)!
        imageView = UIImageView(image: image)
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let image = imageView.image!
        let minHorizontalZoomScale = scrollView.frame.size.width / image.size.width
        let minVerticalZoomScale = scrollView.frame.size.height / image.size.height
        let minZoomScale = min(minHorizontalZoomScale, minVerticalZoomScale)
        scrollView.minimumZoomScale = minZoomScale
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        let horizontalContentInset = (scrollView.frame.size.width - image.size.width * minZoomScale) / 2
        let verticalContentInset = (scrollView.frame.size.height - image.size.height * minZoomScale) / 2
        scrollView.contentInset = UIEdgeInsetsMake(verticalContentInset, horizontalContentInset, verticalContentInset, horizontalContentInset)
    }

}

extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
