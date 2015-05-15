//
//  GalleryView.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 11/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class GalleryView: UIView {
    
    private var imageViews = [UIImageView]()
    private var pageContol = UIPageControl()
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.bounces = true
        return scrollView
    }()
    
    func addImage(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageViews.append(imageView)
        scrollView.addSubview(imageView)
        pageContol.numberOfPages = imageViews.count
        self.layoutSubviews()
        self.updatePageControl()
    }
    
    func clear() {
        for imageView in imageViews { imageView.removeFromSuperview() }
        imageViews.removeAll(keepCapacity: false)
        scrollView.contentSize = CGSizeZero
        pageContol.numberOfPages = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        pageContol.center = CGPointMake(CGRectGetMidX(self.bounds), self.bounds.size.height - 20)
        var contentWidth: CGFloat = 0
        for imageView in imageViews {
            imageView.frame = CGRectMake(contentWidth, 0, self.bounds.size.width, self.bounds.size.height)
            contentWidth += self.bounds.size.width
        }
        scrollView.contentSize = CGSizeMake(contentWidth, self.bounds.size.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        self.addSubview(scrollView)
        self.addSubview(pageContol)
    }
    
    private func updatePageControl() {
        let currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width
        pageContol.currentPage = Int(currentPage)
    }

}

extension GalleryView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updatePageControl()
    }
    
}
