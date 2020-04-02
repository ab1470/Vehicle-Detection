//
//  BoundingBoxView.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Lightly adatpted from

import Foundation
import UIKit

class BoundingBoxView {
    let shapeLayer: CAShapeLayer
    
    init() {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.isHidden = true
    }
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
    }
    
    func show(frame: CGRect, color: UIColor) {
        CATransaction.setDisableActions(true)
        
        let path = UIBezierPath(rect: frame)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
    }
    
    func hide() {
        shapeLayer.isHidden = true
    }
}
