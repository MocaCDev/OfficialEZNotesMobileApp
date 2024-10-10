//
//  Untitled.swift
//  EZNotes-2
//
//  Created by Aidan White on 9/27/24.
//

import AVFoundation
import CoreImage

class FrameHandler: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var frameScale: Double = 1.01
    @Published var currentZoom: Double = 0.0
    @Published var permissionGranted = true
    @Published var currentSession: AVCaptureDevice.DeviceType = .builtInDualCamera
    
    public let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    
    override init() {
        super.init()
        self.checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.permissionGranted = true
                
            case .notDetermined: // The user has not yet been asked for camera access.
                self.requestPermission()
                
            // Combine the two other cases into the default case
            default:
                self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupCaptureSession() -> Void {
        self.videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) else { return }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        self.videoDeviceInput = deviceInput
        
        guard captureSession.canAddInput(self.videoDeviceInput!) else { return }
        
        /* TODO: What preset is going to work best? We want the app to be as light-weight as possible (preferrably). */
        captureSession.sessionPreset = .high//.hd4K3840x2160//.sessionPreset = .photo
        
        captureSession.addInput(self.videoDeviceInput!)
        
        do {
            try self.videoDeviceInput?.device.lockForConfiguration()
            self.videoDeviceInput?.device.videoZoomFactor = 123
            self.videoDeviceInput?.device.unlockForConfiguration()
        } catch let error {
            print(error)
            return
        }
        
        self.videoOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(self.videoOutput!)
        
        /*let previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(captureSession) as AVCaptureVideoPreviewLayer
        previewLayer.frame = view.bounds
        captureSession.layer.addSublayer(previewLayer)*/
        
        self.videoOutput!.connection(with: .video)?.videoRotationAngle = 90
    }
    
    /* MARK: `deviceType` - 0 for `.builtInDualCamera`, 1 for `.builtInTelephotoCamera`. */
    func changeCaptureSession(deviceType: Int) -> Void {
        var device: AVCaptureDevice.DeviceType = .builtInDualCamera
        
        if deviceType == 1 { device = .builtInTelephotoCamera }
        
        captureSession.removeInput(self.videoDeviceInput!)
        
        guard let videoDevice = AVCaptureDevice.default(device, for: .video, position: .back) else { return }
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        self.videoDeviceInput = deviceInput
        
        self.videoOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addInput(self.videoDeviceInput!)
        
        self.videoOutput!.connection(with: .video)?.videoRotationAngle = 90
    }
}


extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        // All UI updates should be/ must be performed on the main queue.
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return cgImage
    }
    
}
