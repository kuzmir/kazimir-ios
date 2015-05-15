//
//  GalleryView.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 11/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class GalleryView: UIScrollView {
    
    func addImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }

    override func layoutSubviews() {
        var contentWidth: CGFloat = 0
        for view in self.subviews as! [UIView] {
            view.frame = CGRectOffset(self.bounds, contentWidth, 0.0)
            contentWidth += self.bounds.size.width
        }
        self.contentSize = CGSizeMake(contentWidth, self.bounds.size.height)
    }

}
