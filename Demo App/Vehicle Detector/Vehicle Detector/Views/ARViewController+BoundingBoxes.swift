//
//  ARViewController+BoundingBoxes.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/2/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Code lightly adapted from Apple's `MLDice` sample app


import UIKit
import Vision

extension ARViewController {
    /// Sets up CALayers for rendering bounding boxes
    func setupLayers() {
        DispatchQueue.main.async {
            self.detectionOverlay = CALayer() // container layer that has all the renderings of the observations
            self.detectionOverlay.name = "DetectionOverlay"
            self.detectionOverlay.bounds = CGRect(x: 0.0,
                                                  y: 0.0,
                                                  width: self.sceneView.frame.width,
                                                  height: self.sceneView.frame.height)
            self.detectionOverlay.position = CGPoint(x: self.rootLayer.bounds.midX,
                                                     y: self.rootLayer.bounds.midY)
            self.rootLayer.addSublayer(self.detectionOverlay)
        }
    }

    /// Update the size of the overlay layer if the sceneView size changed
    func updateDetectionOverlaySize() {
        DispatchQueue.main.async {
            self.detectionOverlay.bounds = CGRect(x: 0.0,
                                                  y: 0.0,
                                                  width: self.sceneView.frame.width,
                                                  height: self.sceneView.frame.height)
        }
    }

    /// Update layer geometry when needed
    func updateLayerGeometry() {
        DispatchQueue.main.async {
            let bounds = self.rootLayer.bounds
            var scale: CGFloat

            let xScale: CGFloat = bounds.size.width / self.sceneView.frame.height
            let yScale: CGFloat = bounds.size.height / self.sceneView.frame.width

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

    /// Removes all bounding boxes from the screen
    func removeBoxes() {
        drawBoxes(observations: [])
    }

    /// Draws bounding boxes based on the object observations
    ///
    /// - parameter observations: The list of object observations from the object detector
    func drawBoxes(observations: [VNRecognizedObjectObservation]) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.detectionOverlay.sublayers = nil // remove all the old recognized objects

            for observation in observations {
                let objectBounds = self.bounds(for: observation)

                let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)

                self.detectionOverlay.addSublayer(shapeLayer)
            }

            self.updateLayerGeometry()
            CATransaction.commit()
        }
    }
}

