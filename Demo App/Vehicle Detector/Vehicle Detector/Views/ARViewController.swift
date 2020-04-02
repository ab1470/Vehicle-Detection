//
//  FirstViewController.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 3/31/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//
//  Code lightly adapted from

import CoreMedia
import UIKit
import Vision


class ARViewController: UIViewController {
    
    @IBOutlet weak var videoPreview: UIView!
    
    var videoCapture: VideoCapture!
    var currentBuffer: CVPixelBuffer?
    
    lazy var vehicleModel: VNCoreMLModel = {
        do {
            let model = try VNCoreMLModel(for: VehicleDetector().model)
            // Use a threshold provider to specify custom thresholds for the object detector.
            model.featureProvider = ThresholdProvider()
            return model
        } catch {
            fatalError("Failed to load the Vision ML model: \(error)")
        }
    }()
    
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: vehicleModel, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        
        // NOTE: If you use another crop/scale option, you must also change
        // how the BoundingBoxView objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    
    let maxBoundingBoxViews = 6
    var boundingBoxViews = [BoundingBoxView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBoundingBoxViews()
        setUpCamera()
    }
    
    
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
            boundingBoxViews.append(BoundingBoxView())
        }
    }
    
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        
        videoCapture.setUp(sessionPreset: .hd1280x720) { success in
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // Add the bounding box layers to the UI, on top of the video preview.
                for box in self.boundingBoxViews {
                    box.addToLayer(self.videoPreview.layer)
                }
                
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    
    func predict(sampleBuffer: CMSampleBuffer) {
        if currentBuffer == nil, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            currentBuffer = pixelBuffer
            
            // Get additional info from the camera.
            var options: [VNImageOption : Any] = [:]
            if let cameraIntrinsicMatrix = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                options[.cameraIntrinsics] = cameraIntrinsicMatrix
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: options)
            do {
                try handler.perform([self.visionRequest])
            } catch {
                print("Failed to perform Vision request: \(error)")
            }
            
            currentBuffer = nil
        }
    }
    
    
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                self.show(predictions: results)
            } else {
                self.show(predictions: [])
            }
        }
    }
    
    
    func show(predictions: [VNRecognizedObjectObservation]) {
        for i in 0..<boundingBoxViews.count {
            if i < predictions.count {
                let prediction = predictions[i]

                /*
                 The predicted bounding box is in normalized image coordinates, with
                 the origin in the lower-left corner.

                 Scale the bounding box to the coordinate system of the video preview,
                 which is as wide as the screen and has a 16:9 aspect ratio. The video
                 preview also may be letterboxed at the top and bottom.

                 Based on code from https://github.com/Willjay90/AppleFaceDetection

                 NOTE: If you use a different .imageCropAndScaleOption, or a different
                 video resolution, then you also need to change the math here!
                 */

                let width = view.bounds.width
                let height = width * 16 / 9
                let offsetY = (view.bounds.height - height) / 2
                let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height - offsetY)
                let rect = prediction.boundingBox.applying(scale).applying(transform)
                
                // Show the bounding box.
                boundingBoxViews[i].show(frame: rect, color: .blue)
            } else {
                boundingBoxViews[i].hide()
            }
        }
    }
}


extension ARViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        predict(sampleBuffer: sampleBuffer)
    }
}
