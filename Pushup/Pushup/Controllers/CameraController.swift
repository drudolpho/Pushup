//
//  CameraController.swift
//  Pushup
//
//  Created by Dennis Rudolph on 4/19/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

class CameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //Controllers
    var testController = TestController()
    var audioController: AudioController?
    var pushupController: PushupController?
    
    var allowedToStartTrackingBrightness = false
    var allowedToAddPushup = false
    var keyValueSet = false
    var keyValueBrightness: Double = 0.0
    var startBrightness: Double = 0.0
    var lowestBrightness: Double = 999.0
    var highDip: Double = -999.0
    var currentBrightness: Double = 0.0 {
        didSet {
            
            //TESTING
            testController.rawValues.append(currentBrightness)
            //TESTING
            
            calculateBrightnessLogic()
        }
    }
    
    lazy var captureSession = AVCaptureSession()
    lazy var videoOutput = AVCaptureVideoDataOutput()
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.currentBrightness = getBrightness(sampleBuffer: sampleBuffer) * 100
    }
    
    private func getBrightness(sampleBuffer: CMSampleBuffer) -> Double {
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        let brightnessValue : Double = exifData?[kCGImagePropertyExifBrightnessValue as String] as! Double
        return brightnessValue
    }
    
    func captureStartingBrightness() {
        allowedToStartTrackingBrightness = true
        keyValueBrightness = currentBrightness
        keyValueSet = true
        startBrightness = currentBrightness
    }
    
    func reset() {
        keyValueBrightness = 0
        allowedToAddPushup = false
        allowedToStartTrackingBrightness = false
    }
    
    //Helper Methods
    
    private func calculateBrightnessLogic() {
        // Calculate if it was a valid pushup
        guard allowedToStartTrackingBrightness == true else { return }
        var roomValue = 100.0
        
        if keyValueSet {
            //Depending on the darkness of the room
            if keyValueBrightness < 350 {
                roomValue = 75.0
            } else {
                roomValue = 100.0
            }
            if currentBrightness < keyValueBrightness - roomValue {
                allowedToAddPushup = true
                if currentBrightness < lowestBrightness {
                    lowestBrightness = currentBrightness
                }
            }
            if allowedToAddPushup {
                if currentBrightness > lowestBrightness + roomValue {
                    pushupController?.pushupCount += 1
                    audioController?.playChosenAudio(pushups: pushupController?.pushupCount)
                    keyValueSet = false
                    keyValueBrightness = -999.0
                    lowestBrightness = 999.0
                }
            }
        } else {
            //Set key value
            if currentBrightness > keyValueBrightness {
                if currentBrightness < startBrightness {
                    keyValueBrightness = currentBrightness
                } else {
                    keyValueBrightness = startBrightness
                }
            }
            if currentBrightness < keyValueBrightness - 50 {
                keyValueSet = true
            }
        }
    }
    
    func setUpCamera() {
        let camera = bestCamera()
        
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Cannot create camera input")
        }
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("Cannot add camera input to session")
        }
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        let videoQueue = DispatchQueue(label: "VIDEO_QUEUE")
        
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        captureSession.addOutput(videoOutput)
        
        captureSession.commitConfiguration()
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front) {
            return device
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            return device
        }

        fatalError("No cameras on the device. Or you are running on the Simulator (not supported)")
    }
}
