//
//  BoundingBoxes.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit
import Vision


protocol VisionBBoxDrawable {
    var detectionOverlay: CALayer { get set }
}

extension VisionBBoxDrawable where Self: UIView {
    
    func setupLayers() {
        DispatchQueue.main.async {
            self.detectionOverlay.name = "DetectionOverlay"
//            self.detectionOverlay.bounds = CGRect(x: 0.0,
//                                                  y: 0.0,
//                                                  width: self.frame.width,
//                                                  height: self.frame.height)
            self.detectionOverlay.frame = self.frame
            self.detectionOverlay.position = CGPoint(x: self.bounds.midX,
                                                     y: self.bounds.midY)
//            self.layer.addSublayer(self.detectionOverlay)
            self.layer.insertSublayer(self.detectionOverlay, above: self.layer)
        }
    }
    
    
    func bounds(for observation: VNRecognizedObjectObservation) -> CGRect {
        let boundingBox = observation.boundingBox
        // Coordinate system is like macOS; origin is on bottom-left, not top-left

        // The resulting bounding box from the prediction is a normalized bounding box with coordinates from bottom left
        // It needs to be flipped along the y axis
        let correctedBoundingBox = CGRect(x: boundingBox.origin.x,
                                      y: 1.0 - boundingBox.origin.y - boundingBox.height,
                                      width: boundingBox.width,
                                      height: boundingBox.height)

        let scaledBBox = VNImageRectForNormalizedRect(correctedBoundingBox, Int(self.frame.width), Int(self.frame.height))

        // Return a flipped and scaled rectangle corresponding to the coordinates in the sceneView
        return scaledBBox
    }


    /// Creates a reounded rectangle layer with the given bounds
    /// - parameter bounds: The bounds of the rectangle
    /// - returns: A newly created CALayer
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.8, 1.0, 0.3])
        shapeLayer.borderWidth = 2
        shapeLayer.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.8, 1.0, 1])
        shapeLayer.cornerRadius = 14
        return shapeLayer
    }


    /// Draws bounding boxes based on the object observations
    ///
    /// - parameter observations: The list of object observations from the object detector
    func drawBoxes(for observations: [VNRecognizedObjectObservation]) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.detectionOverlay.sublayers = nil // remove all the old recognized objects

            for observation in observations {
                let objectBounds = self.bounds(for: observation)
                let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
                self.detectionOverlay.addSublayer(shapeLayer)
            }

//            self.updateLayerGeometry()
            CATransaction.commit()
        }
    }
    
    /// Update layer geometry when needed
    func updateLayerGeometry() {
        DispatchQueue.main.async {
            let bounds = self.bounds
            var scale: CGFloat

            let xScale: CGFloat = bounds.size.width / self.frame.height
            let yScale: CGFloat = bounds.size.height / self.frame.width

            scale = fmax(xScale, yScale)
            if scale.isInfinite {
                scale = 1.0
            }
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

            self.detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)

            CATransaction.commit()
        }
    }


    /// Removes all bounding boxes from the screen
    func removeBoxes() {
        drawBoxes(for: [])
    }

    
}






