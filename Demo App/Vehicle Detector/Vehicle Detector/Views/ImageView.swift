//
//  ImageView.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit

class ImageView: UIView, VisionBBoxDrawable {
    var detectionOverlay: CALayer = CALayer()
    var imageView: UIImageView = UIImageView()
    var image: UIImage? {
        willSet {
            imageView.image = newValue
            self.removeBoxes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupLayers()

        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.frame = frame
        self.addSubview(imageView)
    }

}
