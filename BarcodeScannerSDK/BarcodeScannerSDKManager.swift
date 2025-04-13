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
public struct BarcodeConfiguration: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let vibration = BarcodeConfiguration(rawValue: 1 << 0)
    public static let playSound = BarcodeConfiguration(rawValue: 1 << 1)
    public static let displayBoundingBox = BarcodeConfiguration(rawValue: 1 << 2)
}

public class BarcodeScannerSDKManager: NSObject {
    class BarcodeScannerSDKManagerInternal: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var view: UIView?
        var handler: BarcodeScannerResultBlock?
        private var boundingBox = CAShapeLayer()
        var configuration: BarcodeConfiguration?
        var queue: DispatchQueue?
        
        public override init() {
            self.captureSession = AVCaptureSession()
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            captureSession.stopRunning()
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                guard let localConfiguration = configuration else { return }
                if (localConfiguration.contains(.vibration)) {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                if (localConfiguration.contains(.playSound)) {
                    // 1057 is a standard SMS received sound
                    AudioServicesPlaySystemSound(SystemSoundID(1057))
                }
                if (localConfiguration.contains(.displayBoundingBox)) {
                    guard let transformedObject = previewLayer.transformedMetadataObject(for: readableObject) as? AVMetadataMachineReadableCodeObject else {
                        return
                    }
                    updateBoundingBox(transformedObject.corners)
                }
                guard let localHander = self.handler, let localQueue = self.queue else { return }
                localQueue.async {
                    localHander(stringValue, nil)
                }
            }
        }
        
        fileprivate func setupBoundingBox(_ color: UIColor) {
            guard let localView = self.view else {
                return
            }
            boundingBox.frame = localView.layer.bounds
            boundingBox.strokeColor = color.cgColor
            boundingBox.lineWidth = 4.0
            boundingBox.fillColor = UIColor.clear.cgColor

            localView.layer.addSublayer(boundingBox)
        }
        
        private func updateBoundingBox(_ points: [CGPoint]) {
            guard let firstPoint = points.first else {
                return
            }
            
            let path = UIBezierPath()
            path.move(to: firstPoint)
            
            var newPoints = points
            newPoints.removeFirst()
            newPoints.append(firstPoint)
            
            newPoints.forEach { path.addLine(to: $0) }
            
            boundingBox.path = path.cgPath
            boundingBox.isHidden = false
        }
        
        fileprivate func resetViews() {
            boundingBox.isHidden = true
        }
    }
    
    var internalManager: BarcodeScannerSDKManagerInternal!
    public override init() {
        super.init()
        internalManager = BarcodeScannerSDKManagerInternal()
    }
    
    public func startUpdates(view: UIView, queue: DispatchQueue, configuration:BarcodeConfiguration, boundingBoxColor: UIColor = UIColor.red, codeTypes:[AVMetadataObject.ObjectType], handler: @escaping BarcodeScannerResultBlock) {
        self.internalManager.queue = queue
        queue.sync {
            if (internalManager.captureSession?.isRunning == false) {
                self.internalManager.view = view
                self.internalManager.handler = handler
                guard let view = internalManager.view else {
                    return
                }
                
                view.backgroundColor = UIColor.black
                DispatchQueue.main.async {
                    self.internalManager.setupBoundingBox(boundingBoxColor)
                }
                self.internalManager.configuration = configuration
                
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
                    metadataOutput.metadataObjectTypes = codeTypes
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
    }
    
    public func restartUpdates() {
        if (internalManager.captureSession?.isRunning == false) {
            internalManager.captureSession.startRunning()
            internalManager.resetViews()
        }
    }
    
    public func stopUpdates() {
        if (internalManager.captureSession?.isRunning == true) {
            internalManager.captureSession.stopRunning()
        }
    }
    
    func failed() {
        guard let localHander = self.internalManager.handler, let localQueue = self.internalManager.queue else { return }
        localQueue.async {
            localHander(nil, BarcodeError.notSupported)
        }
    }
}
