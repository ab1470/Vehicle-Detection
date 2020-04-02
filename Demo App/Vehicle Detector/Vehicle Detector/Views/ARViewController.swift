//
//  FirstViewController.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 3/31/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Code lightly adapted from Apple's `MLDice` sample app


import UIKit
import SceneKit
import ARKit
import Vision
import PencilKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /// Concurrent queue to be used for model predictions
    let predictionQueue = DispatchQueue(label: "predictionQueue",
                                        qos: .userInitiated,
                                        attributes: [],
                                        autoreleaseFrequency: .inherit,
                                        target: nil)

    /// The ARSceneView
    @IBOutlet weak var sceneView: ARSCNView!

    /// Layer used to host detectionOverlay layer
    var rootLayer: CALayer!
    /// The detection overlay layer used to render bounding boxes
    var detectionOverlay: CALayer!

    /// Whether the current frame should be skipped (in terms of model predictions)
    var shouldSkipFrame = 0
    /// How often (in terms of camera frames) should the app run predictions
    let predictEvery = 3

    /// Vision request for the detection model
    var vehicleDetectionRequest: VNCoreMLRequest!

    /// Flag used to decide whether to draw bounding boxes for detected objects
    var showBoxes = true {
        didSet {
            if !showBoxes {
                removeBoxes()
            }
        }
    }

    /// Size of the camera image buffer (used for overlaying boxes)
    var bufferSize: CGSize! {
        didSet {
            if bufferSize != nil {
                if oldValue == nil {
                    setupLayers()
                } else if oldValue != bufferSize {
                    updateDetectionOverlaySize()
                }
            }

        }
    }

    /// The last known image orientation
    /// When the image orientation changes, the buffer size used for rendering boxes needs to be adjusted
    var lastOrientation: CGImagePropertyOrientation = .right
    var lastObservations = [VNRecognizedObjectObservation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Set the session's delegate
        sceneView.session.delegate = self

        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene

        // Get the root layer so in order to draw rectangles
        rootLayer = sceneView.layer

        // Load the detection models
        /// - Tag: SetupVisionRequest
        guard let detector = try? VNCoreMLModel(for: VehicleDetector().model) else {
            print("Failed to load detector!")
            return
        }

        // Use a threshold provider to specify custom thresholds for the object detector.
        detector.featureProvider = ThresholdProvider()

        vehicleDetectionRequest = VNCoreMLRequest(model: detector) { [weak self] request, error in
            self?.detectionRequestHandler(request: request, error: error)
        }
        
        vehicleDetectionRequest.imageCropAndScaleOption = .scaleFill
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Disable dimming for demo
        UIApplication.shared.isIdleTimerDisabled = true

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    func bounds(for observation: VNRecognizedObjectObservation) -> CGRect {
        let boundingBox = observation.boundingBox
        // Coordinate system is like macOS, origin is on bottom-left and not top-left

        // The resulting bounding box from the prediction is a normalized bounding box with coordinates from bottom left
        // It needs to be flipped along the y axis
        let fixedBoundingBox = CGRect(x: boundingBox.origin.x,
                                      y: 1.0 - boundingBox.origin.y - boundingBox.height,
                                      width: boundingBox.width,
                                      height: boundingBox.height)

        // Return a flipped and scaled rectangle corresponding to the coordinates in the sceneView
        return VNImageRectForNormalizedRect(fixedBoundingBox, Int(sceneView.frame.width), Int(sceneView.frame.height))
    }

    // MARK: - Vision Callbacks

    /// Handles results from the detection requests
    ///
    /// - parameters:
    ///     - request: The VNRequest that has been processed
    ///     - error: A potential error that may have occurred
    func detectionRequestHandler(request: VNRequest, error: Error?) {
        // Perform several error checks before proceeding
        if let error = error {
            print("An error occurred with the vision request: \(error.localizedDescription)")
            return
        }
        guard let request = request as? VNCoreMLRequest else {
            print("Vision request is not a VNCoreMLRequest")
            return
        }
        guard let observations = request.results as? [VNRecognizedObjectObservation] else {
            print("Request did not return recognized objects: \(request.results?.debugDescription ?? "[No results]")")
            return
        }

        guard !observations.isEmpty else {
            removeBoxes()
            lastObservations = []
            return
        }

        if showBoxes {
            drawBoxes(observations: observations)
        }

    }
}
