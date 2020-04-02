//
//  SecondViewController.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 3/31/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import UIKit
import Vision
import ImageIO

class ImageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mediaTableView: UITableView!
    @IBOutlet weak var helperLabel: UILabel!
    
    @IBOutlet weak var galleryButton: RoundedButton!
    @IBOutlet weak var cameraButton: RoundedButton!
    
    var imagePicker: ImagePicker!
    
    var media = [VehicleObject]() {
        didSet {
            helperLabel.isHidden = self.media.isEmpty ? false : true
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        self.mediaTableView.delegate = self
        self.mediaTableView.dataSource = self
        
        helperLabel.isHidden = self.media.isEmpty ? false : true
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mediaTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
    }
    
    
    @IBAction func showGalleryPicker(_ sender: UIButton) {
        self.imagePicker.showPicker(from: .savedPhotosAlbum)
    }
    
    
    @IBAction func showCamera(_ sender: Any) {
        self.imagePicker.showPicker(from: .camera)
    }
    
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return media.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mediaTableView.dequeueReusableCell(withIdentifier: "ImageCell") as! ImageCell
        
        let vehicleObject = media[indexPath.row]
        let image = vehicleObject.image
        
        cell.imageContainer.image = image
        cell.isProcessing = vehicleObject.isProcessing ? true : false
        
        if let observations = vehicleObject.observations {
            if observations.isEmpty {
                cell.noAutomobiles = true
            } else {
                cell.noAutomobiles = false
                cell.imageContainer.drawBoxes(for: observations)
            }
        }
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let vehicleObject = media[indexPath.row]
        let image = vehicleObject.image!
        
        let cropRatio = image.getCropRatio()
        
        return tableView.frame.width / cropRatio
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            media.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Vision Requests
    func detectVehicles(for vehicleObject: VehicleObject) {
        guard let vehicleImage = vehicleObject.image else { return }
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(vehicleImage.imageOrientation.rawValue)) else { return }
        guard let ciImage = CIImage(image: vehicleImage) else { fatalError("Unable to create \(CIImage.self) from \(vehicleImage).") }
        
        vehicleObject.isProcessing = true
        mediaTableView.reloadData()
        
        let detectionRequest = VNCoreMLRequest(model: vehicleModel, completionHandler: { [weak self] request, error in
            self?.processDetection(for: request, in: vehicleObject, error: error)
        })
        detectionRequest.imageCropAndScaleOption = .scaleFill
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([detectionRequest])
            } catch {
                print("Failed to perform the vehicle detection request.\n\(error.localizedDescription)")
            }
        }
    }
    
    
    func processDetection(for request: VNRequest, in vehicleObj: VehicleObject, error: Error?) {
        DispatchQueue.main.async {
            defer {
                vehicleObj.isProcessing = false
                self.mediaTableView.reloadData()
            }
            
            guard let results = request.results else { return }
            
            let observations = results as! [VNRecognizedObjectObservation]
                        
            if observations.isEmpty {
                print("no automobiles found in photo")
                vehicleObj.observations = []
                
            } else {
                vehicleObj.observations = observations
            }
        }
    }
        
}

// MARK: - Select Image
extension ImageViewController: ImagePickerDelegate {
    func didSelect(_ image: UIImage?) {
        guard var image = image else { return }
        image = image.fixOrientation() ?? image
        
        let vehicleObject = VehicleObject(image: image)
        media.insert(vehicleObject, at: 0)
                        
        detectVehicles(for: vehicleObject)
    }
    
}
