//
//  CVPixelBuffer.swift
//  PhotoBooth
//
//  Created by turru-and-gors on 2019-11-03.
//  Copyright © 2019 turru-and-gors. All rights reserved.
//

import CoreML
import Cocoa

/**
 @brief Created this extension of CVPixelBuffer to handle the conversion to NSImage
 */
extension CVPixelBuffer {
    /**@brief conversion to NSImage
     @param context CIContext to handle the conversion to CIImage. Creating a CIContext is expensive, so create just one on your main code and share it with this conversion function.
     @param rect Describe the rectangle containing the viewer where you will display the NSImage.
     */
    func toNSImage(context: CIContext, rect: NSRect) -> NSImage?
    {
        let ciImage = CIImage(cvPixelBuffer: self)
        guard let cgImage = context.createCGImage(ciImage, from: rect)
            else { return nil }
        
        let imageSize = NSSize(width: cgImage.width, height: cgImage.height)
        return NSImage(cgImage: cgImage, size: imageSize)
    }
    
    /**@brief conversion to CIImage*/
    func toCIImage() -> CIImage?
    {
        return CIImage(cvPixelBuffer: self)
    }
}
