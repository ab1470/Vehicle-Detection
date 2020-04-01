//
//  VehicleObject.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit

class VehicleObject {
    var isRecognizing: Bool = false
    var image: UIImage!
    var boundingBoxes: [CGRect] = []
    
    init(image: UIImage) {
        self.image = image
    }
}
