//
//  UIImage+Extension.swift
//  Vehicle Detector
//
//  Created by Andrew Balmer on 4/1/20.
//  Copyright © 2020 Andrew Balmer. All rights reserved.
//

import UIKit

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}
