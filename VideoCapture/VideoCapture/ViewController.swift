//
//  ViewController.swift
//  VideoCapture
//
//  Created by turru-and-gors on 2019-11-03.
//  Copyright © 2019 turru-and-gors. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    // Connection with the image view added on the Main.storyboard
    @IBOutlet weak var imageView: NSImageView!
    
    // Object of class VideoCapture
    var videoCapture : VideoCapture!
    // Core-Image context ---> useful to convert CVPixelBuffer to CIImage
    let context = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a new object of class VideoCapture
        videoCapture = VideoCapture()
        // Declare resolution... if you change this value, change also
        // the size of the viewer in Main.storyboard
        videoCapture.resolution = .vga640x480
        // This object (ViewController) is a delegate from VideoCapture
        videoCapture.delegate = self
    }
    
    // If for some reason the view will dissapear,
    // stop camera capture
    override func viewWillDisappear() {
        videoCapture.stopCamera()
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    
}

// Create an extension of the ViewController to manage the
// VideoCapture's captured function.
// This function could also be declared inside ViewController,
// by inherinting ViewController from VideoCaptureOSXDelegate
extension ViewController : VideoCaptureOSXDelegate {
    // This function receives a CVPixelBuffer as input argument,
    // Inside the captured function we will convert the CVPixelBuffer
    // to NSImage --> requested to display the capture on an imageView
    func captured(pixelBuffer: CVPixelBuffer) {
    
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: view.bounds)
            else { return }
        
        let imageSize = NSSize(width: cgImage.width, height: cgImage.height)
        let nsImage = NSImage(cgImage: cgImage, size: imageSize)
        
        imageView.image = nsImage
    }
}
