//
//  VehicleObject.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import Vision

class VehicleObject {
    var isProcessing: Bool = false
    var image: UIImage!
    var observations: [VNRecognizedObjectObservation]?
    
    init(image: UIImage) {
        self.image = image
    }
}
