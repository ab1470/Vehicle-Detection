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
    
    var media = [UIImage]() {
        didSet {
            helperLabel.isHidden = self.media.isEmpty ? false : true
        }
    }
    
    lazy var detectionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: VehicleDetector().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processDetection(for: request, error: error)
            })
            //            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        self.mediaTableView.delegate = self
        self.mediaTableView.dataSource = self
        self.mediaTableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "ImageTableViewCell")
        
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
        let cell = mediaTableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as! ImageTableViewCell
        
        cell.mainImageView.image = media[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentImage = media[indexPath.row]
        let cropRatio = currentImage.getCropRatio()
        
        return tableView.frame.width / cropRatio
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            media.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Vision Requests
    func detectVehicles(in image: UIImage) {
        //    classificationLabel.text = "Classifying..."
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else { return }
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.detectionRequest])
            } catch {
                print("Failed to perform the vehicle detection request.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processDetection(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                //            self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            
            let observations = results as! [VNRecognizedObjectObservation]
            
            if observations.isEmpty {
                //            self.classificationLabel.text = "Nothing recognized."
            } else {
                print(observations.count)
                print(observations[0])
                // Display top classifications ranked by confidence in the UI.
                //            let topClassifications = classifications.prefix(2)
                //            let descriptions = topClassifications.map { classification in
                //                // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                //               return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                //            }
                //            self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
}

// MARK: - Select Image
extension ImageViewController: ImagePickerDelegate {
    func didSelect(_ image: UIImage?) {
        guard let image = image else { return }
        media.insert(image, at: 0)
        mediaTableView.reloadSections([0], with: .automatic)
        detectVehicles(in: image)
    }
    
}

