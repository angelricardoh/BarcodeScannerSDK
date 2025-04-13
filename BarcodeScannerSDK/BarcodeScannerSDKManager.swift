//
//  BarcodeScannerSDKManager.swift
//  BarcodeScannerSDK
//
//  Created by Angel Ricardo Nieto Garcia on 4/12/25.
//

import AVFoundation
import UIKit

public typealias BarcodeScannerResultBlock = (_ result: String?, _ error: BarcodeError?) -> Void
public enum BarcodeError: Error {
    case notSupported
    case unexpected
}

public class BarcodeScannerSDKManager: NSObject {
    class BarcodeScannerSDKManagerInternal: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var view: UIView?
        var handler: BarcodeScannerResultBlock?
        
        public override init() {
            self.captureSession = AVCaptureSession()
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                guard let localHander = self.handler else { return }
                localHander(stringValue, nil)
            }
        }
    }
    
    var internalManager: BarcodeScannerSDKManagerInternal!
    public override init() {
        super.init()
        internalManager = BarcodeScannerSDKManagerInternal()
    }
    
    public func startUpdates(view: UIView, handler: @escaping BarcodeScannerResultBlock) {
        if (internalManager.captureSession?.isRunning == false) {
            self.internalManager.view = view
            self.internalManager.handler = handler
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
        guard let localHander = internalManager.handler else { return }
        localHander(nil, BarcodeError.notSupported)
    }
}
