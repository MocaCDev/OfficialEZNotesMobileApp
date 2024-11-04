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
    @Published var permissionGranted: Bool = true
    @Published var cameraDeviceFound: Bool = true
    
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
                self.requestPermission()
                self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            DispatchQueue.main.async { self.permissionGranted = granted }
        }
    }
    
    private func getListOfCameras() -> [AVCaptureDevice] {
        
    #if os(iOS)
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInWideAngleCamera,
                .builtInTelephotoCamera
            ],
            mediaType: .video,
            position: .unspecified)
    #elseif os(macOS)
        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .unspecified)
    #endif
        
        return session.devices
    }
    
    func setupCaptureSession() -> Void {
        self.videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        let devices: [AVCaptureDevice] = self.getListOfCameras()
        var devicesNames: [String] = []
        
        for device in devices {
            devicesNames.append(device.localizedName)
        }
        
        print("DEVICES: \(devicesNames)")
        
        var videoDevice: AVCaptureDevice! = nil
        
        if devicesNames.contains("Back Triple Camera") {
            videoDevice = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back)
        } else {
            if devicesNames.contains("Back Dual Camera") {
                videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
            } else {
                videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            }
        }
        
        guard videoDevice != nil else { return }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            self.cameraDeviceFound = false
            return
        }
        self.videoDeviceInput = deviceInput
        
        guard captureSession.canAddInput(self.videoDeviceInput!) else { return }
        
        /* TODO: What preset is going to work best? We want the app to be as light-weight as possible (preferrably). */
        captureSession.sessionPreset = .inputPriority//.hd4K3840x2160//.sessionPreset = .photo
        
        captureSession.addInput(self.videoDeviceInput!)
        
        self.videoOutput!.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(self.videoOutput!)
        
        /*let previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(captureSession) as AVCaptureVideoPreviewLayer
        previewLayer.frame = view.bounds
        captureSession.layer.addSublayer(previewLayer)*/
        
        if #available(iOS 17.0, *) {
            self.videoOutput!.connection(with: .video)?.videoRotationAngle = 90
        } else {
            // Fallback on earlier versions
            self.videoOutput!.connection(with: .video)?.videoOrientation = .portrait
        }
        
        guard let device = self.videoDeviceInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = device.minAvailableVideoZoomFactor//max(device.minAvailableVideoZoomFactor, max(factor, device.minAvailableVideoZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setScale(scale: CGFloat) -> Void {
        guard let device = self.videoDeviceInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, max(scale, device.minAvailableVideoZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
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
