//
//  SecondViewController.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 3/31/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import Foundation
import UIKit

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
    
}


extension ImageViewController: ImagePickerDelegate {
    func didSelect(_ image: UIImage?) {
        guard let image = image else { return }
        media.insert(image, at: 0)
        mediaTableView.reloadSections([0], with: .automatic)
    }
    
}

