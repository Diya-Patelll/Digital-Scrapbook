//
//  CropPicker.swift
//  Scrapbook
//
//  Created by Diya Patel on 3/17/26.
//

import SwiftUI
import TOCropViewController

struct CropPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropViewController = TOCropViewController(image: image ?? UIImage())
        
        // handles user actions
        cropViewController.delegate = context.coordinator
        cropViewController.aspectRatioLockEnabled = false
        cropViewController.toolbarPosition = .bottom
        cropViewController.doneButtonTitle = "Save"

        return cropViewController
    }
    
    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}
    
    // coordinator that acts as a bridge between UIkit and SwiftUI
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // coordinator class handles TOCropview delegate methods
    class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: CropPicker
        
        init(parent: CropPicker) {
            self.parent = parent
        }
        
        // user finishes cropping
        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
                    parent.image = image
                    parent.dismiss()
        }
        
        // user taps X
        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            parent.dismiss()
        }
    }
}
