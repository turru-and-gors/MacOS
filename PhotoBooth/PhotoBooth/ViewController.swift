//
//  ViewController.swift
//  PhotoBooth
//
//  Created by turru-and-gors on 2019-11-03.
//  Copyright © 2019 turru-and-gors. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    /**@brief Enumerate all possible image processing algorithms - for simplicity*/
    enum imageProcess {
        case none
        case gray
        case sepia
    }
    
    @IBOutlet weak var imageView: NSImageView!
    
    var videoCapture : VideoCapture!
    let context = CIContext()
    var processOnImage : imageProcess = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoCapture = VideoCapture()
        videoCapture.resolution = .vga640x480
        videoCapture.delegate = self
    }
    
    override func viewWillDisappear() {
        videoCapture.stopCamera()
    }

    override var representedObject: Any? {
        didSet {
        
        }
    }

    // This function handles all the radio buttons behavior
    // First, get the selected radio button, and then
    // choose the right image processing algorithm
    @IBAction func optionSelected(_ sender: Any) {
        let button : NSButton = sender as! NSButton
        
        switch button.title {
        case "Original":
            processOnImage = imageProcess.none
        case "Gray":
            processOnImage = imageProcess.gray
        case "Sepia":
            processOnImage = imageProcess.sepia
        default:
            processOnImage = imageProcess.none
        }
    }
    
}

extension ViewController : VideoCaptureOSXDelegate {
    func captured(pixelBuffer: CVPixelBuffer) {
        // get the original image, then apply the selected image
        // processing algorithm to it
        let originalImage = pixelBuffer.toCIImage()
        let image : NSImage!
        switch processOnImage {
        case .none:
            image = originalImage?.toNSImage(context: context)
        case .gray:
            let gray = originalImage?.toGrayscale(context: context)
            image = gray?.toNSImage(context: context)
        case .sepia:
            let sepia = originalImage?.toSepia(context: context)
            image = sepia?.toNSImage(context: context)
        }
        
        // Send the resulting image to the image view
        imageView.image = image
    }
}
