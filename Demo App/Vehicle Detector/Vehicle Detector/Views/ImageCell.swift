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
    @IBOutlet weak var imageContainer: ImageView!
    @IBOutlet weak var imageOverlay: UIView!
    @IBOutlet weak var noAutomobilesLabel: UILabel!
        
    var isProcessing: Bool = false {
        didSet {
            if isProcessing {
                imageOverlay.isHidden = false
                activityIndicator.startAnimating()
            } else {
                imageOverlay.isHidden = true
                activityIndicator.stopAnimating()
            }
        }
    }
    
    var noAutomobiles: Bool = false {
        didSet {
            if noAutomobiles {
                noAutomobilesLabel.isHidden = false
                imageOverlay.isHidden = false
            } else {
                noAutomobilesLabel.isHidden = true
                imageOverlay.isHidden = true
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityIndicator.hidesWhenStopped = true
        imageOverlay.backgroundColor = .systemGroupedBackground
        imageOverlay.alpha = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageContainer.removeBoxes()
    }

}
