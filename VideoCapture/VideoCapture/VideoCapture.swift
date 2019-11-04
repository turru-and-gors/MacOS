//
//  VideoCapture.swift
//  VideoCapture
//
//  Created by turru-and-gors on 2019-11-03.
//  Copyright © 2019 turru-and-gors. All rights reserved.
//

import Cocoa
import AVFoundation

/**
 @brief VideoCaptureOSXDelegate Declare your viewer class a delegate from this protocol to handle each captured frame
 @discussion Implement the "captured" method to handle every captured frame as a CVPixelBuffer.
 */
protocol VideoCaptureOSXDelegate : class {
    func captured(pixelBuffer : CVPixelBuffer)
}

/**
 @brief VideoCapture Handle video capture from default embedded camera.
 @param delegate Make your viewer class a delegate of this object.
 @param resolution Define the size of the captured frames.
 */
class VideoCapture: NSObject {
    // Public attributes
    weak var delegate : VideoCaptureOSXDelegate?
    public var resolution = AVCaptureSession.Preset.vga640x480
    
    // Private attributes
    private let captureSession = AVCaptureSession()
    // Create a serial queue that will handle the work related to the session
    private let sessionQueue = DispatchQueue(label: "session queue")
    // If permission granted, start camera capture
    private var permissionGranted : Bool = false
    
    
    // Public method --- Call this when you need to stop the camera capture
    func stopCamera(){
        captureSession.stopRunning()
    }
    
    
    override init() {
        super.init()
        
        // Camera capture will be performed in a different thread,
        // main thread will be used only to display the captured image.
        sessionQueue.async {
            [unowned self] in
            self.checkAuthorization()
            if self.permissionGranted {
                self.configCapture()
                self.captureSession.startRunning()
            }
        }
    }
    
    
    // Check if user has already granted capture permission, or ask for permission
    // to handle camera.
    private func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.permissionGranted = true
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.permissionGranted = true
                    }
                }
            
            case .denied: // The user has previously denied access.
                self.permissionGranted = false
                return

            case .restricted: // The user can't grant access due to restrictions.
                self.permissionGranted = false
                return
            
        @unknown default:
            self.permissionGranted = false
        }
    }
    
    
    // Configure the capture input and output.
    // INPUT --> video camera
    // OUTPUT -> Video data output
    private func configCapture() {
        // Start configuration
        captureSession.beginConfiguration()
            // ==================================================
            // -----> INPUT
            let device = AVCaptureDevice.devices(for: .video)
            let videoDevice = device.first
            //let videoDevice = AVCaptureDevice.default(for: .video)
            guard
                let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
                captureSession.canAddInput(videoDeviceInput)
                else { return }
            captureSession.addInput(videoDeviceInput)
        
            // -----> OUTPUT
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
            guard captureSession.canAddOutput(videoOutput)
                else { return }
            captureSession.sessionPreset = resolution
            captureSession.addOutput(videoOutput)
            // ==================================================
        // Finish configuration
        captureSession.commitConfiguration()
    }
}


extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate {
    // Handle captured frames
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // Convert to pixelBuffer -- good option for CoreML and Core Image processing
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Dispatch pixel buffer to delegate in main thread
        DispatchQueue.main.async {
            [unowned self] in
            self.delegate?.captured(pixelBuffer: imageBuffer)
        }
    }
}
