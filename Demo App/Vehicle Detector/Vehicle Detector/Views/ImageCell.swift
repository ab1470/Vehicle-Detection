//
//  ImageCell.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var vehicleImage: UIImageView!
    
    lazy var processingOverlay: UIView = {
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        overlay.backgroundColor = .systemGroupedBackground
        overlay.alpha = 0.5
        return overlay
    }()
    
    var isProcessing: Bool = false {
        didSet {
            if isProcessing {
                self.addSubview(processingOverlay)
                processingOverlay.frame = vehicleImage.frame
                activityIndicator.startAnimating()
            } else {
                processingOverlay.removeFromSuperview()
                activityIndicator.stopAnimating()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        activityIndicator.hidesWhenStopped = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
