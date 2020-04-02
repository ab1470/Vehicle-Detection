//
//  ImagePicker.swift
//  Violations
//
//  Created by Andrew Balmer on 4/1/20.
//  Lightly adapted from https://theswiftdev.com/2019/01/30/picking-images-with-uiimagepickercontroller-in-swift-5/
//

import UIKit
import Photos

public protocol ImagePickerDelegate: class {
    func didSelect(_ image: UIImage?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.showPicker(from: type)
        }
    }
    
    
    public func showPicker(from source: UIImagePickerController.SourceType) {
        
        if source == .savedPhotosAlbum && PHPhotoLibrary.authorizationStatus() == .notDetermined {
            DispatchQueue.main.async {
                PHPhotoLibrary.requestAuthorization { _ in
                    DispatchQueue.main.async {
                        self.showPicker(from: source)
                    }
                }
            }
            
            return
        }
        
        self.pickerController.sourceType = source
        self.presentationController?.present(self.pickerController, animated: true)
    }
    
        
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image)
    }
}


extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        
        self.pickerController(picker, didSelect: image)
    }
    
}


extension ImagePicker: UINavigationControllerDelegate {
    
}
