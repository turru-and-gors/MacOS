//
//  CIImage.swift
//  PhotoBooth
//
//  Created by turru-and-gors on 2019-11-04.
//  Copyright © 2019 turru-and-gors. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

extension CIImage {
    // Convert CIImage to NSImage
    func toNSImage(context: CIContext) -> NSImage? {
        guard let cgImage = context.createCGImage(self, from: self.extent) else { return nil }
        
        // Create and return the UIImage
        let imageSize = NSSize(width: cgImage.width, height: cgImage.height)
        return NSImage(cgImage: cgImage, size: imageSize)
    }
    
    // APPLY FILTER:
    // 1. Instantiate a CIFilter object representing the filter to apply
    // 2. Provide an image as input to the filter (and the rest of parameters if apply)
    // 3. Get a CIImage object representing the filter’s output.
    // 4. Render the output image to a Core Graphics image that you can display or save to a file.
    
    // -----> CONVERT TO GRAYSCALE
    func toGrayscale(context: CIContext) -> CIImage? {
        // CIPhotoEffectNoir
        guard let filter = CIFilter(name: "CIMinimumComponent") else { return nil }
        filter.setValue(self, forKey: kCIInputImageKey)
        return applyFilter(filter: filter, context: context)
    }
    
    // -----> CONVERT TO SEPIA
    func toSepia(context: CIContext) -> CIImage? {
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(0.7, forKey: kCIInputIntensityKey)
        return applyFilter(filter: filter, context: context)
    }
    
    // -----> CONVERT TO SKETCH
    func highlight(context: CIContext) -> CIImage? {
        guard let filter = CIFilter(name: "CIGloom") else { return nil }
        filter.setValue(self, forKey: kCIInputImageKey)
        return applyFilter(filter: filter, context: context)
    }
    
    // -----> SHARPEN
    func sharpen(context: CIContext) -> CIImage? {
        guard let filter = CIFilter(name: "CISharpenLuminance") else { return nil }
        filter.setValue(self, forKey: kCIInputImageKey)
        return applyFilter(filter: filter, context: context)
    }
    
    
    // -----> APPLY FILTER
    private func applyFilter(filter: CIFilter, context: CIContext) -> CIImage? {
        let result = filter.outputImage!
        guard let cgImage = context.createCGImage(result, from: result.extent) else { return nil }
        return CIImage(cgImage: cgImage)
    }
}
