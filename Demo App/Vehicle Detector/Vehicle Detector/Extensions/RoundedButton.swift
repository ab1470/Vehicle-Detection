//
//  RoundedButton.swift
//  Violations
//
//  Created by Andrew Balmer on 11/13/19.
//

import UIKit

class RoundedButton: UIButton {
    let cornerRadius = Constants.Button.cornerRadius
    
    override func awakeFromNib() {
        layer.cornerRadius = cornerRadius
    }
}
