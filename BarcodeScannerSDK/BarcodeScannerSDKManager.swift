//
//  BarcodeScannerSDKManager.swift
//  BarcodeScannerSDK
//
//  Created by Angel Ricardo Nieto Garcia on 4/12/25.
//

import AVFoundation
import UIKit

public class BarcodeScannerSDKManager: NSObject {
    class BarcodeScannerSDKManagerInternal: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var view: UIView?
        var manager: BarcodeScannerSDKManager?
        
        public init(_ manager: BarcodeScannerSDKManager) {
            self.manager = manager;
            self.captureSession = AVCaptureSession()
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print(stringValue)
            }
        }
    }
    
    var internalManager: BarcodeScannerSDKManagerInternal!
    public override init() {
        super.init()
        internalManager = BarcodeScannerSDKManagerInternal(self)
    }
    
    public func startUpdates(view: UIView) {
        
        if (internalManager.captureSession?.isRunning == false) {
            self.internalManager.view = view
            guard let view = internalManager.view else {
                return
            }
            
            view.backgroundColor = UIColor.black
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }
            
            if (internalManager.captureSession.canAddInput(videoInput)) {
                internalManager.captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (internalManager.captureSession.canAddOutput(metadataOutput)) {
                internalManager.captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(internalManager, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
            } else {
                failed()
                return
            }
            
            internalManager.previewLayer = AVCaptureVideoPreviewLayer(session: internalManager.captureSession)
            internalManager.previewLayer.frame = view.layer.bounds
            internalManager.previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(internalManager.previewLayer)
            internalManager.captureSession.startRunning()
        }
    }
    
    public func restartUpdates() {
        if (internalManager.captureSession?.isRunning == false) {
            internalManager.captureSession.startRunning()
        }
    }
    
    public func stopUpdates() {
        if (internalManager.captureSession?.isRunning == true) {
            internalManager.captureSession.stopRunning()
        }
    }
    
    func failed() {
        print("failed")
        // TODO: Throw error
//        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
//        captureSession = nil
    }
    
    func found(code: String) {
        print(code)
    }
}
